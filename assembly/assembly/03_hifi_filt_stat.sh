#!/bin/sh
#SBATCH --job-name=CCSfilt
#SBATCH --partition=cpu64
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=250g
#SBATCH --time=900:00:00

date

ID="XX"
threads=20

###Note the bam file suffix and directory!!!
mv */*hifi_reads.bam* ./
mv */*/*hifi_reads.bam* ./

ls *.hifi_reads.bam|while read a
do
	pre=`echo $a|sed 's/.hifi_reads.bam//g'`
 	##https://github.com/sheinasim/HiFiAdapterFilt
	hifiadapterfilt.sh -l 44 -m 97 -t ${threads} -p $pre
	rm -f ${pre}.hifi_reads.contaminant.blastout
done

list=`ls *filt.fastq.gz | xargs`
zcat $list | seqkit stats -aT -j ${threads} -t dna > $ID\_hifi.stat

echo "HiFi filtering finished..."
