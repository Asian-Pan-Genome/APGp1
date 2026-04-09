#!/bin/bash

if [[ $# != 2 ]]; then
	echo "Usage: sh $0 sample_ID hap[MAT|PAT]"
	exit 1
fi

id=$1
hap=$2
wk=`pwd`
src=$(cd $(dirname $0);pwd)

# get data
source $src/init.conf
R7_GapFilling_assembly="${DATA}/assembly/${id}/R7_GapFilling_assembly"
PHASED_ONT="${DATA}/Nanopore/${id}-01/binning/haplotype"

# check assembly
if [ -e $R7_GapFilling_assembly/${hap}_ragtag/${id}_${hap}_scaffold.fasta ]; then
	[ -e ${id}_${hap}_scaffold.fasta ] || ln -s $R7_GapFilling_assembly/${hap}_ragtag/${id}_${hap}_scaffold.fasta .
else
	echo "Can not find genome assembly..."
	exit 1
fi

# check meryl DB
if [ ! -e $R7_GapFilling_assembly/${hap}_ragtag/${id}_${hap}_repetitive_k15.txt ]; then
	echo "try to find repetitive_k15.txt from $R7_GapFilling_assembly/${hap}_ragtag/${id}_${hap}_repetitive_k15.txt"
	echo "Not found, let's make it..."
	meryl count k=15 output merylDB ${id}_${hap}_scaffold.fasta
	meryl print greater-than distinct=0.9998 merylDB > repetitive_k15.txt && rm merylDB
	echo "make repetitive_k15.txt done!"
else
	cp $R7_GapFilling_assembly/${hap}_ragtag/${id}_${hap}_repetitive_k15.txt ./repetitive_k15.txt
fi

# check bam
if [ -e $wk/${id}_${hap}-unknown_ONT.sort.bam ] && [ -e $wk/${id}_${hap}-unknown_ONT.sort.bam.bai ]; then
	echo "[INFO]: ${id}_${hap}-unknown_ONT.sort.bam found, do nothing"
	exit 0
else
	if [ -e $wk/${id}_${hap}_ONT.sort.bam ] && [ -e $wk/${id}_unknown_ONT.sort.bam  ]; then
		echo "[INFO]: find ${id}_${hap}_ONT.sort.bam and ${id}_unknown_ONT.sort.bam, then merge and index..."
		echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=24\n#SBATCH --partition=cpu\n#SBATCH --mem=30g\n"  >mapping.sh
		echo "${SAMTOOLS} merge -@ 24 -f -o $wk/${id}_${hap}-unknown_ONT.sort.bam $wk/${id}_${hap}_ONT.sort.bam $wk/${id}_unknown_ONT.sort.bam" >> mapping.sh
		echo "${SAMTOOLS} index $wk/${id}_${hap}-unknown_ONT.sort.bam && touch mapping.finished " >> mapping.sh
		exit 0
	fi

fi
# check ${hap} ONT mapping
if [ -e ${id}_${hap}_ONT.sort.bam ]; then
	echo "[INFO]: find ${hap} ONT read mapping result..."
else
	if [ -e ${id}_${hap}_ONT.bam ]; then
		echo "${id}_${hap}_ONT.sort.bam not found... OK, let's do it"
		echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=24\n#SBATCH --partition=cpu\n#SBATCH --mem=30g\n"  >mapping.sh
		echo "${SAMTOOLS} sort -@ 24 -o $wk/${id}_${hap}_ONT.sort.bam $wk/${id}_${hap}_ONT.bam" >> mapping.sh

	else
		if [ -e $R7_GapFilling_assembly/${hap}_ragtag/${id}_${hap}_ONT.bam ]; then
			ln -s $R7_GapFilling_assembly/${hap}_ragtag/${id}_${hap}_ONT.bam ./
			echo "find ${id}_${hap}_ONT.bam but not sorted... OK, let's do it"
			echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=24\n#SBATCH --partition=cpu\n#SBATCH --mem=30g\n"  >mapping.sh
			echo "${SAMTOOLS} sort -@ 24 -o $wk/${id}_${hap}_ONT.sort.bam $wk/${id}_${hap}_ONT.bam" >> mapping.sh
		else
			echo "[INFO]: ${hap} ONT read mapping result not found..., OK, let's do it"
			echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=24\n#SBATCH --partition=cpu\n#SBATCH --mem=30g\n"  >mapping.sh
			echo "${WINNOWMAP} -W $wk/repetitive_k15.txt -t 12 -ax map-ont  $wk/${id}_${hap}_scaffold.fasta ${PHASED_ONT}/haplotype-${hap}.fasta.gz | ${SAMTOOLS} view -bh -@ 12 > $wk/${id}_${hap}_ONT.bam && echo 'mapping done' " >> mapping.sh
			echo "${SAMTOOLS} sort -@ 24 -o $wk/${id}_${hap}_ONT.sort.bam $wk/${id}_${hap}_ONT.bam && echo 'sort done' "
		fi
	fi
fi
		
# check unknown ont mapping
if [ -e $wk/${id}_unknown_ONT.sort.bam ]; then
	echo "[INFO]: found ${id}_unknown_ONT.sort.bam"
else
	if [ -e ${id}_unknown_ONT.bam ]; then
		echo "find ${id}_${hap}_ONT.bam but not sorted... OK, let's do it"
		[ -s mapping.sh ] ||  echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=24\n#SBATCH --partition=cpu\n#SBATCH --mem=30g\n"  >mapping.sh
		echo "${SAMTOOLS} sort -@ 24 -o $wk/${id}_${hap}_ONT.sort.bam $wk/${id}_${hap}_ONT.bam" >> mapping.sh
	else
		echo "[INFO]: unknown ONT read mapping result not found..., OK, let's do it"
		[ -s mapping.sh  ] || echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=24\n#SBATCH --partition=cpu\n#SBATCH --mem=30g\n"  >mapping.sh
		echo "${WINNOWMAP} -W $wk/repetitive_k15.txt -t 12 -ax map-ont  $wk/${id}_${hap}_scaffold.fasta ${PHASED_ONT}/haplotype-unknown.fasta.gz | ${SAMTOOLS} view -bh -@ 12 > $wk/${id}_unknown_ONT.bam && echo 'mapping done' " >> mapping.sh
		echo "${SAMTOOLS} sort -@ 24 -o $wk/${id}_unknown_ONT.sort.bam $wk/${id}_unknown_ONT.bam && echo 'sort done' " >> mapping.sh
	fi
fi


[ -s mapping.sh   ] || echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=24\n#SBATCH --partition=cpu\n#SBATCH --mem=30g\n"  >mapping.sh
echo "${SAMTOOLS} merge -@ 24 -f -o $wk/${id}_${hap}-unknown_ONT.sort.bam $wk/${id}_${hap}_ONT.sort.bam $wk/${id}_unknown_ONT.sort.bam" >> mapping.sh
echo "${SAMTOOLS} index $wk/${id}_${hap}-unknown_ONT.sort.bam && touch mapping.finished" >> mapping.sh


