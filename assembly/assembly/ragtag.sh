#!/bin/sh
#SBATCH --job-name=ragtagMat_R4ctg_R3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem=200g
#SBATCH --time=900:00:00

date

threads=60
famID="C010-CHA-E10"
hifi=`ls /slurm/users/wudongya/APG/PB/CCS/${famID}-01/*.filt.fastq.gz |xargs`
ont=`ls /slurm/users/wudongya/APG/Nanopore/${famID}-01/*pass_100k.fastq.gz |xargs | sed "s/ /,/g"`

ragtag.py patch C010-CHA-E10_hifiasm_trio_ont.dip.hap2_ctg.fa assembly.haplotype2_contig.fasta -f 5000 --remove-small -t ${threads} --aligner /slurm/soft/canu/2.2/bin/minimap2 -o Mat_R4ctg_R3_ragtag
