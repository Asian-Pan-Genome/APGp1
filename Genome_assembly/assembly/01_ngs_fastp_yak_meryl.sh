#!/usr/bin/bash
#SBATCH --job-name=C081-01
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=200g
#SBATCH --time=900:00:00

date

threads=30
#1: child; #2: paternal; #3: yak: maternal;
ID = 1

mv */*fq.gz ./

echo "DATA QC and FILTERING..."
ls *_1.fq.gz|while read a
do
        pre=`echo $a|sed 's/_1.fq.gz//g'`
        echo $pre
        fastp -i $pre\_1.fq.gz -o $pre\_1.clean.fq.gz -I $pre\_2.fq.gz -O $pre\_2.clean.fq.gz -j $pre.json -h $pre.html -u 30 -q 20 -w $threads
done
echo "QC Finished!"

###buiding kmer library for HIFIASM
echo "Yak K-mer..."
################
#1.yak offspring  #2.yak paternal  #3.yak maternal
yak count -k31 -b37 -o ${ID}.yak -t ${threads} <(zcat *.clean.fq.gz) <(zcat *.clean.fq.gz)
echo "yak K-mer Finished!"

###building kmer library for VERKKO
echo "Meryl K-mer..."
mem="250g"
ls *.clean.fq.gz|while read a
do
        pre=`echo $a|sed 's/.clean.fq.gz//g'`
        meryl k=30 threads=${threads} memory=$mem count compress output $pre\.meryl $pre\.clean.fq.gz
done
meryl threads=${threads} memory=$mem union-sum output ${ID}\.merys *.meryl
rm -rf *.meryl
mv ${ID}\.merys ${ID}\.meryl
echo "Meryl K-mer Finished!"

###To confirm the trio kinship
####################
###Mapping to CHM13v2
####################
echo "downsaple to 30X"
zcat *_1.clean.fq.gz | seqkit head -n 500000000 | gzip > $sample\_33X_R1.fq.gz
zcat *_2.clean.fq.gz | seqkit head -n 500000000 | gzip > $sample\_33X_R2.fq.gz
ref_genome="/YOUR_PATH/CHM13v2m.fasta"
RG="@RG\tID:${sample}\tSM:${sample}\tLB:LIB\tPL:BGI"
echo "33XDS mapping to CHM13"
bwa mem $ref_genome $sample\_33X_R1.fq.gz $sample\_33X_R2.fq.gz -t $threads -R "$RG" > $sample\.sam
samtools view -@ $threads -bS $sample\.sam > $sample\.bam
samtools sort -@ $threads $sample\.bam -o $sample\.sorted.bam
rm -f $sample\.bam
rm -f $sample\.sam
samtools index -@ $threads $sample\.sorted.bam
samtools flagstat -@ $threads $sample\.sorted.bam > $sample\.flagstat
echo "Mapping and sorting Finished!"

echo "Finished!"
date
