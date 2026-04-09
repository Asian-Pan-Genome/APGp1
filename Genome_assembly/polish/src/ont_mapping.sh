#!/bin/bash

if [[ $# != 3 ]]; then
	echo "Usage: sh $0 sample_ID hap[MAT|PAT] draft"
	exit 1
fi

id=$1
hap=$2
draft=$(realpath $3)

wk=`pwd`
src=$(cd $(dirname $0);pwd)

# CONFIGURE OF DATA, SOFTWARE..
if [ -s $src/init.conf   ]; then
	echo "Load configure from $src/init.conf"
	source $src/init.conf
else
	echo "Can not assess to init.conf in $src"
	exit -1
fi

PHASED_ONT="$ONT/${id}-01/binning/haplotype"
# $HIFI, $SGE_THREADS1, $SGE_THREADS2, $SGE_MEM

outpre="ont2asm"

# check assembly
if [ ! -s $draft ]; then
	echo "draft genome is invalid, please give rigth one..."
	exit 1
fi


# check final bam
if [ -e $wk/${id}_${hap}-unknown_ONT.sort.bam ] && [ -e $wk/${id}_${hap}-unknown_ONT.sort.bam.bai ]; then
	echo "[INFO]: ${id}_${hap}-unknown_ONT.sort.bam found, do nothing"
	exit 0
fi

# check ${hap} ONT mapping
echo "[INFO]: ${hap} ONT read mapping result not found..., OK, let's do it"
echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=$SGE_THREADS2\n#SBATCH --partition=cpu\n#SBATCH --mem=$SGE_MEM\n"  >ont_mapping.sh
echo "winnowmap -W $wk/repetitive_k15.txt -t $SGE_THREADS1 -ax map-ont  ${draft} $DATA/haplotype-${hap}.fasta.gz | samtools view -bh -@ $SGE_THREADS1 > $wk/${id}_${hap}_ONT.bam && echo 'mapping done' " >> ont_mapping.sh
echo "samtools sort -@ $SGE_THREADS2 -o $wk/${id}_${hap}_ONT.sort.bam $wk/${id}_${hap}_ONT.bam && echo 'sort done' "
		
# check unknown ont mapping
echo "[INFO]: unknown ONT read mapping result not found..., OK, let's do it"
echo "winnowmap -W $wk/repetitive_k15.txt -t $SGE_THREADS1 -ax map-ont  ${draft} $DATA/haplotype-unknown.fasta.gz | samtools view -bh -@ $SGE_THREADS1 > $wk/${id}_unknown_ONT.bam && echo 'mapping done' " >> ont_mapping.sh
echo "samtools sort -@ $SGE_THREADS2 -o $wk/${id}_unknown_ONT.sort.bam $wk/${id}_unknown_ONT.bam && echo 'sort done' " >> ont_mapping.sh

# merge two sets
echo "samtools merge -@ $SGE_THREADS2 -f -o $wk/$outpre.ont.sort.bam $wk/${id}_${hap}_ONT.sort.bam $wk/${id}_unknown_ONT.sort.bam" >> ont_mapping.sh
echo "samtools index $wk/$outpre.ont.sort.bam" >> ont_mapping.sh
echo "python3 $src/filterClipForBam.py $wk/$outpre.ont.sort.bam -o $wk/$outpre.ont.sort.filt_clip.bam -cp 1000" >> ont_mapping.sh
echo "samtools index $wk/$outpre.ont.sort.filt_clip.bam" >> ont_mapping.sh


