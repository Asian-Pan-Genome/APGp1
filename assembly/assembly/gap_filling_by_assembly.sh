#!/bin/sh
#SBATCH --job-name=C088gf
#SBATCH --partition=cpu64
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200g
#SBATCH --time=300:00:00

date

threads=30
famID="C088-CHA-C08"
wkdir="/share/home/project/zhanglab/APG/Assembly"

echo "## Checking assemblies!"

###verkko TRIO assemblies
if [ ! -d "${wkdir}/${famID}-01/R3_verkko_trio_ont/verkko" ]; then
	echo ">> no verkko TRIO assemblies !"
	exit
else
	echo ">> verkko TRIO assemblies found!"
	ln -s ${wkdir}/${famID}-01/R3_verkko_trio_ont/verkko/${famID}_assembly.haplotype1_contig.fasta ${famID}_verkko_pat_ctg.fasta
	ln -s ${wkdir}/${famID}-01/R3_verkko_trio_ont/verkko/${famID}_assembly.haplotype2_contig.fasta ${famID}_verkko_mat_ctg.fasta
fi

###hifiasm TRIO assemblies
if [ ! -d "${wkdir}/${famID}-01/R4_hifiasm_trio_ont_update" ]; then
	echo ">> no hifiasm TRIO assemblies !"
	exit
else
	echo ">> hifiasm TRIO assemblies found!"
	ln -s ${wkdir}/${famID}-01/R4_hifiasm_trio_ont_update/${famID}_hifiasm_trio_ont.dip.hap1_ctg.fa ${famID}_hifiasmTrio_pat_ctg.fasta
	ln -s ${wkdir}/${famID}-01/R4_hifiasm_trio_ont_update/${famID}_hifiasm_trio_ont.dip.hap2_ctg.fa ${famID}_hifiasmTrio_mat_ctg.fasta
fi

###hifiasm HIC assemblies
if [ ! -d "${wkdir}/${famID}-01/R5_hifiasm_hic_ont" ]; then
        echo ">> no hifiasm HIC assemblies !"
        exit
else    
        echo ">> hifiasm HIC assemblies found!"
        ln -s ${wkdir}/${famID}-01/R5_hifiasm_hic_ont/${famID}.fa_trioC_pat ${famID}_hifiasmHiC_pat_ctg.fasta
        ln -s ${wkdir}/${famID}-01/R5_hifiasm_hic_ont/${famID}.fa_trioC_mat ${famID}_hifiasmHiC_mat_ctg.fasta
fi

<<EOF
###flye assemblies
if [ ! -d "${wkdir}/${famID}-01/R6_flye_trio_ont" ]; then
        echo ">> no flye assemblies !"
        exit
else    
        echo ">> flye assemblies found!"
        ln -s ${wkdir}/${famID}-01/R6_flye_trio_ont/${famID}_flye_Pat_ctg.fasta ${famID}_flye_pat_ctg.fasta
        ln -s ${wkdir}/${famID}-01/R6_flye_trio_ont/${famID}_flye_Mat_ctg.fasta ${famID}_flye_mat_ctg.fasta
fi
EOF

###merge assemblies
echo "##PAT from ${famID} gap filling by assemblies starts..."
echo ">> 1. Gap filling by hifiasm HIC assemblies..."
perl ${wkdir}/R7_gap_filling_by_assembly.pl ${famID}_hifiasmTrio_pat_ctg.fasta ${famID}_hifiasmHiC_pat_ctg.fasta ${famID}_pat_R4_R5
echo ">> 1. Finished!"

echo ">> 2. Gap filling by verkko assemblies..."
perl ${wkdir}/R7_gap_filling_by_assembly.pl ${famID}_pat_R4_R5.paf.fasta ${famID}_verkko_pat_ctg.fasta ${famID}_Pat_R4_R5_R3
echo ">> 2. Finished!"

<<EOF
echo ">> 3. Gap filling by flye assemblies..."
perl ${wkdir}/R7_gap_filling_by_assembly.pl ${famID}_pat_R4_R5_R3.paf.fasta ${famID}_flye_pat_ctg.fasta ${famID}_Pat_R4_R5_R3_R6
echo ">> 3. Finished!"
EOF

echo ""
echo "##MAT from ${famID} gap filling by assemblies starts..."
echo ">> 1. Gap filling by hifiasm HIC assemblies..."
perl ${wkdir}/R7_gap_filling_by_assembly.pl ${famID}_hifiasmTrio_mat_ctg.fasta ${famID}_hifiasmHiC_mat_ctg.fasta ${famID}_mat_R4_R5
echo ">> 1. Finished!"

echo ">> 2. Gap filling by verkko assemblies..."
perl ${wkdir}/R7_gap_filling_by_assembly.pl ${famID}_mat_R4_R5.paf.fasta ${famID}_verkko_mat_ctg.fasta ${famID}_Mat_R4_R5_R3
echo ">> 2. Finished!"

<<EOF
echo ">> 3. Gap filling by flye assemblies..."
perl ${wkdir}/R7_gap_filling_by_assembly.pl ${famID}_mat_R4_R5_R3.paf.fasta ${famID}_flye_mat_ctg.fasta ${famID}_Mat_R4_R5_R3_R6
echo ">> 3. Finished!"
EOF

echo ""
echo ""
echo "##Final gap-filled assemblies are:"
echo "		Paternal: ${famID}_Pat_R4_R5_R3.paf.fasta"
echo "		Maternal: ${famID}_Mat_R4_R5_R3.paf.fasta"
rm -f *unimap.fmash
rm -f *unimap.paf


########
### scaffolding && ONT mapping
########

echo ""
echo "##Scaffolding to chromosomes!"

###set for ragtag

align="/share/home/zhanglab/user/wudongya/anaconda3/bin/minimap2"

###ref is set as CHM13v2, and may be CN1.
ref="/share/home/project/zhanglab/APG/Reference/CHM13v2m.fasta"

<<EOF
ontdir="/slurm/home/zju/zhanglab/wudongya/APG/Nanopore/${famID}-01/binning/haplotype"

if [ ! -f ${ontdir}/haplotype-Mat.fasta.gz ]; then 
	echo "NO binned ONT reads! && EXIT!"
	exit
else 
	echo ">> binned ONT reads found!"
fi
EOF

for hap in {"Mat","Pat"};
do

###Scaffolding
echo "## Scaffold ${hap} of ${famID}!"
query="${famID}_${hap}_R4_R5_R3.paf.fasta"
ragtag.py scaffold ${ref} ${query} -f 10000 --remove-small -t ${threads} --aligner ${align} -o ${hap}_ragtag
mv ${hap}_ragtag/ragtag.scaffold.fasta ${hap}_ragtag/${famID}_${hap}_scaffold.fasta
mv ${hap}_ragtag/ragtag.scaffold.stats ${hap}_ragtag/${famID}_${hap}_scaffold.stats
mv ${hap}_ragtag/ragtag.scaffold.agp ${hap}_ragtag/${famID}_${hap}_scaffold.agp
mv ${hap}_ragtag/ragtag.scaffold.confidence.txt ${hap}_ragtag/${famID}_${hap}_scaffold.confidence.txt
mv ${hap}_ragtag/ragtag.scaffold.asm.paf ${hap}_ragtag/${famID}_${hap}_scaffold.asm.paf
mv ${hap}_ragtag/ragtag.scaffold.err ${hap}_ragtag/${famID}_${hap}_scaffold.err
mv ${hap}_ragtag/ragtag.scaffold.asm.paf.log ${hap}_ragtag/${famID}_${hap}_scaffold.asm.paf.log

N50 ${hap}_ragtag/${famID}_${hap}_scaffold.fasta ${hap}_ragtag/${famID}_${hap}_scaffold.n50 10000
cat ${hap}_ragtag/${famID}_${hap}_scaffold.agp | grep "^chr" -v | grep -v "#" | grep -v "NC" | cut -f1,3 | sort -k2,2nr > ${hap}_ragtag/${famID}_${hap}_unanchor.list
cat ${hap}_ragtag/${famID}_${hap}_scaffold.agp | awk '$5=="U"{print $1"\t"$2"\t"$3}' > ${hap}_ragtag/${famID}_${hap}_scaffold.gap

<<EOF
###ONT reads mapping
echo ">> Map ONT reads against ${hap} of ${famID}!"
scaf="${hap}_ragtag/${famID}_${hap}_scaffold.fasta"
echo "  ##ONT mapping start!"

##mapping by winnowmap
meryl count threads=${threads} k=15 output ${hap}_ragtag/${hap}_merylDB $scaf
meryl print threads=${threads} greater-than distinct=0.9998 ${hap}_ragtag/${hap}_merylDB > ${hap}_ragtag/${famID}_${hap}_repetitive_k15.txt
winnowmap -W ${hap}_ragtag/${famID}_${hap}_repetitive_k15.txt -t ${threads} -ax map-ont $scaf ${ontdir}/haplotype-${hap}.fasta.gz | samtools view -bh -@ ${threads} > ${hap}_ragtag/${famID}_${hap}_ONT.bam

##mapping by minimap2
minimap2 -x map-ont ${scaf} ${ontdir}/haplotype-${hap}.fasta.gz > ${hap}_ragtag/${famID}_${hap}_ONT_minimap2.paf
echo "  ##ONT mapping done!"
EOF

done

echo ""
echo "R7 steps are done!"
echo "bye!"
