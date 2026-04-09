#!/bin/bash

if [[ $# != 3 ]]; then
	echo "Usage: sh $0 sample_ID hap[MAT|PAT] draft"
	exit 1
fi

id=$1
hap=$2
draft=$(realpath $3)
src=$(cd $(dirname $0);pwd)
wk=`pwd`
outpre="hifi2asm"
repidx="$wk/repetitive_k15.txt"


# CONFIGURE OF DATA, SOFTWARE..
if [ -s $src/init.conf   ]; then
	echo "Load configure from $src/init.conf"
	source $src/init.conf
else
	echo "Can not assess to init.conf in $src"
	exit -1
fi

CCS="$HIFI/CCS/${id}-01"
# $SGE_THREADS1, $SGE_THREADS2, $SGE_MEM, $SGE_PARTITION

echo "#!/bin/bash
#SBATCH --job-name=${id}_hifi
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=$SGE_THREADS2
#SBATCH --partition=$SGE_PARTITION
#SBATCH --mem=$SGE_MEM " > hifi_mapping.sh


for i in `ls $CCS/*.filt.fastq.gz`
do
	filename=`basename $i| sed 's/.hifi_reads.filt.fastq.gz//g'`
	echo "$WINNOWMAP -W $repidx -H -t $SGE_THREADS1 -ax map-pb ${draft} $i|samtools view -bh -@ $SGE_THREADS1 -  > $wk/$filename.hifi.bam "
	echo "samtools sort -@ $SGE_THREADS2 $wk/$filename.hifi.bam > $wk/$filename.hifi.sort.bam "
done >> hifi_mapping.sh

# merge
echo "samtools merge -@ 20 $wk/$outpre.hifi.sort.bam $wk/*.hifi.sort.bam
samtools index $wk/$outpre.hifi.sort.bam
date " >> hifi_mapping.sh
