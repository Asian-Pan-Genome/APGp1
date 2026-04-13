#!/bin/sh
#SBATCH --job-name=IDbiont
#SBATCH --partition all
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=40
#SBATCH --mem=350g
#SBATCH --time=900:00:00

date

threads=40
famID="FAMID[should be replaced]"

ont_100k=`ls /path-to-dir/Nanopore/${famID}-01/*pass_100k.fastq.gz|xargs`

pat_ngs=`ls /path-to-dir/NGS/${famID}-02/*clean.fq.gz|xargs`
mat_ngs=`ls /path-to-dir/NGS/${famID}-03/*clean.fq.gz|xargs`

canu -p asm -d binning_100k genomeSize=3g useGrid=true maxThreads=${threads} -haplotypePat $pat_ngs -haplotypeMat $mat_ngs -nanopore-raw $ont_100k -stopAfter=haplotype -corMhapOptions="--threshold 0.8 --ordered-sketch-size 1000 --ordered-kmer-size 14" -correctedErrorRate=0.105

ont=`ls /path-to-dir/ONT/${famID}-01/*.fastq.gz|xargs`

canu -p asm -d binning genomeSize=3g useGrid=true maxThreads=${threads} -haplotypePat $pat_ngs -haplotypeMat $mat_ngs -nanopore-raw ${ont} -stopAfter=haplotype -corMhapOptions="--threshold 0.8 --ordered-sketch-size 1000 --ordered-kmer-size 14" -correctedErrorRate=0.105
