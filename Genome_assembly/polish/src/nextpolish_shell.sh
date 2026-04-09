#!/bin/bash

if [[ $# != 5  ]]; then
	echo "Usage: sh $0 asm output k21.yak k31.yak hifi2asm.bam"
	exit 1
fi

draft=$(realpath $1)
output=$2
k21=$3
k31=$4
hifi2asm=$5

wk=`pwd`

# CONFIGURE OF DATA, SOFTWARE..
if [ -s $src/init.conf    ]; then
	echo "Load configure from $src/init.conf"
	source $src/init.conf
else
	echo "Can not assess to init.conf in $src"
	exit -1
fi

PHASED_ONT="$ONT/${id}-01/binning/haplotype"
# $HIFI, $SGE_THREADS1, $SGE_THREADS2, $SGE_MEM


echo "#!/bin/bash
#SBATCH --job-name=nextpolish
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --partition=cpu
#SBATCH --mem=100g

date
$NEXTPOLISH -t 2 -r $hifi2asm $input $k21 $k31 > $output
date " > nextPolish.sh
