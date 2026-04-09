#!/bin/sh
#SBATCH --job-name=C010-hicQC
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=200g
#SBATCH --time=900:00:00

date

threads=50
ID=1

mv */*.fq.gz ./

echo "DATA QC and FILTERING..."
ls *_1.fq.gz|while read a
do
        pre=`echo $a|sed 's/_1.fq.gz//g'`
        echo $pre
        ~/software/anaconda/bin/fastp -i $pre\_1.fq.gz -o $pre\_1.clean.fq.gz -I $pre\_2.fq.gz -O $pre\_2.clean.fq.gz -j $pre.json -h $pre.html -u 30 -q 20 -w $threads
done
echo "QC Finished!"

echo "Finished!"
date
