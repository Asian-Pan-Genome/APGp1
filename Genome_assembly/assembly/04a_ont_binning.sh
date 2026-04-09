#!/bin/sh
#SBATCH --job-name=C081biont
#SBATCH --partition all
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=40
#SBATCH --mem=350g
#SBATCH --time=900:00:00

date

threads=40
famID="C081-CHA-C01"

ont_100k=`ls /slurm/users/wudongya/APG/Nanopore/${famID}-01/*pass_100k.fastq.gz|xargs`

pat_ngs=`ls /slurm/users/wudongya/APG/NGS/${famID}-02/*clean.fq.gz|xargs`
mat_ngs=`ls /slurm/users/wudongya/APG/NGS/${famID}-03/*clean.fq.gz|xargs`

canu -p asm -d binning_100k genomeSize=3g useGrid=true maxThreads=${threads} -haplotypePat $pat_ngs -haplotypeMat $mat_ngs -nanopore-raw $ont_100k -stopAfter=haplotype -corMhapOptions="--threshold 0.8 --ordered-sketch-size 1000 --ordered-kmer-size 14" -correctedErrorRate=0.105

ont=`ls /slurm/users/nas-z/wudongya/APG_raw/ONT/${famID}-01/*.fastq.gz|xargs`

canu -p asm -d binning genomeSize=3g useGrid=true maxThreads=${threads} -haplotypePat $pat_ngs -haplotypeMat $mat_ngs -nanopore-raw ${ont} -stopAfter=haplotype -corMhapOptions="--threshold 0.8 --ordered-sketch-size 1000 --ordered-kmer-size 14" -correctedErrorRate=0.105
