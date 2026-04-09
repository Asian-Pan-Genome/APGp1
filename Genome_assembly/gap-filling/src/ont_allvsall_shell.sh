if [[ $# != 1  ]] ; then
	echo "Usage : $0 ont_read"
	exit 1
fi

ont_read=$1
threads=24
src=$(cd $(dirname $0);pwd)
wk=`pwd`

source $src/init.conf

echo "#!/bin/bash
#SBATCH --job-name=ava
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${threads}
#SBATCH --partition=cpu
#SBATCH --mem=100g
date
${MINIMAP2} -x ava-ont -t 24 ${ont_read} > imperfect_read2read.paf
date " 
