#!/bin/sh
#SBATCH --job-name=C081bicanu
#SBATCH --partition all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=200g
#SBATCH --time=900:00:00

date

threads=20

famID="C081-CHA-C01"

hifi=`ls /slurm/users/wudongya/APG/PB/CCS/${famID}-01/*hifi_reads.filt.fastq.gz|xargs`
pat_ngs=`ls /slurm/users/wudongya/APG/NGS/${famID}-02/*clean.fq.gz|xargs`
mat_ngs=`ls /slurm/users/wudongya/APG/NGS/${famID}-03/*clean.fq.gz|xargs`

canu -p asm -d binning genomeSize=3g useGrid=false maxThreads=${threads} -haplotypePat $pat_ngs -haplotypeMat $mat_ngs -pacbio-raw $hifi -stopAfter=haplotype -corMhapOptions="--threshold 0.8 --ordered-sketch-size 1000 --ordered-kmer-size 14" -rawErrorRate=0.010

##split unknown reads into 2 parts
rm -rf binning/haplotype/0-kmers/

seqkit split -j ${threads} -p 2 binning/haplotype/haplotype-unknown.fasta.gz

mv binning/haplotype/haplotype-unknown.fasta.gz.split/* binning/haplotype/
rmdir binning/haplotype/stdin.split
rmdir binning/haplotype/haplotype-unknown.fasta.gz.split
