#!/bin/bash
#SBATCH --partition=cpu64,cpu128
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=40g

prefix=$1
hap=$2

#python blastn2bed.py $prefix/$hap/${prefix}.AS $prefix/$hap/${prefix}_${hap}.as.bed

infile="$prefix/$hap/${prefix}.AS"
tmpfile="$prefix/$hap/${prefix}.as.tmp"

echo $infile
sort -V -k1,1 -k7,7n -k8,8n -k12,12nr $infile | awk '
{
    key = $1 "\t" $7 "\t" $8
    if (key != prev_key) {
        if (NR > 1) {
            if (pident >= 90 && alignlen >= 100) {
                if (qstart < qend && sstart < send) {
                    strand = "+"
                } else {
                    strand = "-"
                }
                print best_line "\t" strand
            }
        }
        prev_key = key
        bitscore = $12
        qstart = $7
        qend = $8
        sstart = $9
        send = $10
        pident = $3
        alignlen = $4
        best_line = $0
    } else {
        if ($12 > bitscore) {
            bitscore = $12
            qstart = $7
            qend = $8
            sstart = $9
            send = $10
            pident = $3
            alignlen = $4
            best_line = $0
        }
    }
}
END {
    if (pident >= 90 && alignlen >= 100) {
        if (qstart < qend && sstart < send) {
            strand = "+"
        } else {
            strand = "-"
        }
        print best_line "\t" strand
    }
}
' | awk '{print $1"\t"$7"\t"$8"\t"$2"\t"$12"\t"$13}' > $tmpfile 

intersect_tmpfile="$prefix/$hap/${prefix}.as.intersect.tmp"
unique_tmpfile="$prefix/$hap/${prefix}.as.unique.tmp"
overlap_id="$prefix/$hap/${prefix}.as.dup.ids"
overlap_tmpfile="$prefix/$hap/${prefix}.as.dup.tmp"
overlap_uniqfile="$prefix/$hap/${prefix}.as.dedup.tmp"
outfile="$prefix/$hap/${prefix}_${hap}.asat.bed"

bedtools intersect -a $tmpfile -b $tmpfile -wa -wb | awk '{print $1"@"$2"@"$3"@"$4"@"$5"@"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12}' > $intersect_tmpfile
cat $intersect_tmpfile | datamash -g 1 count 2 | awk '{if ($2==1)print$1}' | sed "s/@/\t/g" > $unique_tmpfile
cat $intersect_tmpfile | datamash -g 1 count 2 | awk '{if ($2>1)print$1}' > $overlap_id
grep -F -f $overlap_id $intersect_tmpfile > $overlap_tmpfile
awk '{
    if (!($1 in max) || $6 > max[$1]) {
        max[$1] = $6;
        line[$1] = $2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7;
    }
} END {
    for (i in line) {
        print line[i];
    }
}' $overlap_tmpfile | sort | uniq > $overlap_uniqfile
cat $unique_tmpfile $overlap_uniqfile | sort -V -k1,1 -k7,7n -k8,8n -k12,12nr > $outfile
rm $intersect_tmpfile $unique_tmpfile $overlap_id $overlap_tmpfile $overlap_uniqfile

##get centromere alpha bed
cent_ext_5mb="$prefix/$hap/${prefix}.round1.cenpos"
cent_asfile="$prefix/$hap/${prefix}_${hap}.asat.cent.bed"
bedtools intersect -a $outfile -b $cent_ext_5mb -wa > $cent_asfile
echo "get cent asat done!"

##update cenanno
cenanno="$prefix/$hap/${prefix}.round1.cenanno"
update_cenanno="$prefix/$hap/${prefix}.round1.updated.cenanno"
anno_tmpfile="$prefix/$hap/cenanno.tmp.bed"
grep -v "ASat" $cenanno > $anno_tmpfile
cat $cent_asfile $anno_tmpfile | sort -V -k1,1 -k2,2n -k3,3n > $update_cenanno
rm $anno_tmpfile
rm $cenanno
mv $update_cenanno $cenanno
echo "update cenanno done!"

##update mnfasta
assemblyDir="/share/home/project/zhanglab/APG/Public_data/HGSVC3_assembly"
genome="$prefix/$hap/${prefix}_${hap}_chrR.fasta"
if [ ! -f $genome ]; then 
    ln -s $assemblyDir/${prefix}_${hap}_ragtag/${prefix}_${hap}_chrR.fasta $prefix/$hap;
    /share/home/zhanglab/user/sunyanqing/miniconda3/envs/viz/bin/samtools faidx $genome
fi
echo $genome
bedtools getfasta -fi $genome -bed ${cent_asfile} -s -fo $prefix/$hap/${prefix}_${hap}.mn.fasta
echo "get asat monomers done!"
rm $prefix/$hap/${prefix}.mn.fasta

