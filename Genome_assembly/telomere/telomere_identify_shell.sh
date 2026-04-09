if [[ $# != 4 ]] ; then
	echo "Usage : $0 id hap[Mat|Pat] genome.full genome.chr"
	exit 1
fi

wk=`pwd`
src=$(cd $(dirname $0);pwd)

id=$1
hap=$2
genoFull=$3
genoChr=$4

source $src/init.conf

echo "#!/bin/bash
#SBATCH --job-name=${id}_${hap}-TELO
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${SGE_THREADS}
#SBATCH --partition=${SGE_PARTITION}
#SBATCH --mem=${TELO_MEM}
date
source ${ACTIVATE} ${TIDK_ENV}
tidk search  --fasta ${genoFull} --string  TTAGGG --output ${id}_${hap}.full.tidk --dir ./ -w 200
${PYTHON} $src/tidk2teloRegion.py ${id}_${hap}.full.tidk_telomeric_repeat_windows.csv 0.5 > ${id}_${hap}.full.telomere_200_0.5.bed
bedtools merge -i ${id}_${hap}.full.telomere_200_0.5.bed -d 300|sort -k1,1V -k2n > ${id}_${hap}.full.telomere.200_0.5_m300.bed
gzip ${id}_${hap}.full.tidk_telomeric_repeat_windows.csv 
${SAMTOOLS} faidx ${genoChr}
${PYTHON} $src/makeChrEndBed.py ${genoChr}.fai 1000 > ${genoChr}.end.bed
${BEDTOOLS} coverage -a ${genoChr}.end.bed -b ${id}_${hap}.full.telomere_200_0.5.bed |awk '\$8<0.5' |cut -f 1,4 |sort -k1,1V -k2n >  ${genoChr}.teloMiss.txt && touch telo.ok
date "
