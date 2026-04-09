if [[ $# != 3  ]] ; then
	echo "Usage : $0 sampleID *.meryl genome outpre"
	exit 1
fi

id=$1
hap=$2
bam=$3

threads=8

wk=`pwd`

echo "#!/bin/bash
#SBATCH --job-name=filter
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${threads}
#SBATCH --partition=cpu
#SBATCH --mem=5g
date

python3 $src/../common/filterClipForBam.py -cp 100 -o ${bam} > ${bam}.filt.bam
samtools view -@ ${threads} ${bam}.filt.bam|cut -f 1 |sort --parallel=${threads} > perfect_mapped.ont.sort.ids
# all ont ids
pigz -dc -p 8 /share/home/project/zhanglab/APG/ONT/${id}/binning/haplotype/haplotype-${hap}.fasta.gz |grep '>' |sed 's/>//g'  > ${hap}.ids
pigz -dc -p 8 /share/home/project/zhanglab/APG/ONT/${id}/binning/haplotype/haplotype-unknown.fasta.gz |grep '>' |sed 's/>//g'  > unknown.ids
cat ${hap}.ids unknown.ids|sort --parallel=${threads}  >all.ont.sort.ids && rm ${hap}.ids unknown.ids
comm -23 all.ont.sort.ids perfect_mapped.ont.sort.ids > imperfect_mapped.ont.ids
seqtk subseq /share/home/project/zhanglab/APG/ONT/${id}/binning/haplotype/haplotype-${hap}.fasta.gz imperfect_mapped.ont.ids > imperfect_mapped.ont.fa
seqtk subseq /share/home/project/zhanglab/APG/ONT/${id}/binning/haplotype/haplotype-unknown.fasta.gz imperfect_mapped.ont.ids >> imperfect_mapped.ont.fa

date "
