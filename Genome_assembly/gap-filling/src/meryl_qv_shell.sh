if [[ $# != 4 ]] ; then
	echo "Usage : $0 sampleID *.meryl genome outpre"
	exit 1
fi

id=$1
db=$2
genome=$3
outpre=$4

wk=`pwd`
src=$(cd $(dirname $0);pwd)

source $src/init.conf

echo "#!/bin/sh
#SBATCH --job-name=qv
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --partition=${SGE_PARTITION}
#SBATCH --mem=48g

# QV, hybrid
source /slurm/home/zju/zhanglab/yangchentao/miniconda3/bin/activate r
date
sh ${MERQURY_EXE} ${db} ${genome} ${outpre} && touch qv.finish
date "
