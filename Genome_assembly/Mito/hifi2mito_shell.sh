#!/bin/bash

if [[ $# != 1 ]]; then
	echo "Usage: sh $0 sample_ID"
	exit 1
fi

id=$1
src=$(cd $(dirname $0);pwd)
wk=`pwd`

# CONFIGURE OF DATA, SOFTWARE..
if [ -s $src/init.conf   ]; then
	echo "Load configure from $src/init.conf"
	source $src/init.conf
else
	echo "Can not assess to init.conf in $src"
	exit -1
fi

CCS="$HIFI/${id}-01"
# $SGE_THREADS1, $SGE_THREADS2, $SGE_MEM, $SGE_PARTITION

hifi=`ls $CCS/*.filt.fastq.gz|xargs `
echo "#!/bin/bash
#SBATCH --job-name=${id}-mito
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=cpu64,cpu128
#SBATCH --mem=5g
date 
${MINIMAP2}  -t 4 -cx map-hifi $MITO_REF $hifi > $wk/hifi2mito.paf 
date " > hifi2mito.sh
