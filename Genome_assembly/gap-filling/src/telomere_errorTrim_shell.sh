#!/bin/bash

if [[ $# != 5 ]] ; then
	echo "Usage : $0 id hap[Mat|Pat] genome telomere.bed output"
	exit 1
fi

wk=`pwd`
src=$(cd $(dirname $0);pwd)

id=$1
hap=$2
genome=$3
telo=$4
output=$5

source $src/init.conf

echo "date
# detect misassembly in telomere rgion
[ -e ${genome}.fai ] || samtools faidx ${genome}
perl $src/../common/gap2posBed.pl ${genome} > ${genome}.gaps.bed
python3 $src/../telomere/detect_wrongTelo.py ${genome}.fai ${genome}.gaps.bed ${telo}  > teloTrim.edit.bed

if [ -s teloTrim.edit.bed ]; then
	telo_trim=\`wc -l teloTrim.edit.bed\`
	echo \"[INFO]: there are \${telo_trim} can be corrected in this process\"
	echo \">>>>>>Telomere Trimed<<<<<<<\"
	cat teloTrim.edit.bed
	echo \"<<<<<<<<<<<<<<>>>>>>>>>>>>>>\"
	# if esists, remove first, otherwise update_assembly_edits_and_breaks.py can not work
	[ -e ${output} ] && rm ${output}
	# update genome by removing wrongly assembled telomere
	python $src/update_assembly_edits_and_breaks.py -i ${genome} -o ${output} -e teloTrim.edit.bed
	# remove Ns (adjacent gaps)
	bedtools subtract -a teloTrim.edit.bed -b ${genome}.gaps.bed > teloTrim.noN.bed
	# # keep telo trimed sequence still in updated genome
	bedtools getfasta -fi ${genome} -bed teloTrim.noN.bed | sed 's/^>\\S*/&_TeloTrim/g' |fold >> ${output}
	date && echo \"[INFO]: Telomere Trimed done\"
else
	echo \"[INFO]: there is no one telomere need to be corrected in this process\"
	echo \"[INFO]: so that v3 is just a link of v2\"
	ln -s ${genome} ${output}
fi "
