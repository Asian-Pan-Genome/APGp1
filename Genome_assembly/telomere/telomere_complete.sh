#!/bin/bash

if [[ $# != 3 ]]; then
	echo "Usage: $0 ID HAP[Mat|Pat] DRAFT"
	exit 1
fi

ID=$1
HAP=$2
DRAFT=$3
nHAP=''
LEN_CUTOFF=1000000
src=$(cd $(dirname $0);pwd)
CHM13_END="$src/chm13.end.fasta"

if [ $HAP == "Mat" ]; then
	nHAP="1"
elif [ $HAP == "Pat" ]; then
	nHAP="2"
else
	echo "Only accept HAP are Mat and Pat"
fi

ORIGINAL_VERKKO="/slurm/home/zju/zhanglab/wudongya/APG/assembly/${ID}/R3_verkko_trio_ont/verkko/${ID}_assembly.haplotype${nHAP}_contig.fasta"
ORIGINAL_HIFIASM="/slurm/home/zju/zhanglab/wudongya/APG/assembly/${ID}/R4_hifiasm_trio_ont_update/${ID}_hifiasm_trio_ont.dip.hap${nHAP}_ctg.fa"
if [ -e ${ORIGINAL_VERKKO} ]; then
	echo "ORIGINAL VERKKO is: ${ORIGINAL_VERKKO}"
else
	echo "CAN NOT ASSESS TO ORIGINAL VERKKO ASSEMBLY in ${ORIGINAL_VERKKO}"
	exit 1
fi

if [ -e ${ORIGINAL_HIFIASM} ]; then
	echo "ORIGINAL HIFIASM is: ${ORIGINAL_HIFIASM}"
else
	echo "CAN NOT ASSESS TO ORIGINAL HIFIASM ASSEMBLY in ${ORIGINAL_HIFIASM}"
	exit 1
fi

if [ -e ${DRAFT} ]; then
	echo "DRAFT ASSEMBLY is: ${DRAFT}"
else
	echo "CAN NOT ASSESS TO DRAFT ASSEMBLY in ${DRAFT}"
	exit 1
fi
#verkko
$src/fastaKit  -lle ${LEN_CUTOFF} -o ${ID}_${HAP}.verkko.small_contig.fasta ${ORIGINAL_VERKKO}
#hifiasm
$src/fastaKit  -lle ${LEN_CUTOFF} -o ${ID}_${HAP}.hifiasm.small_contig.fasta ${ORIGINAL_HIFIASM}

source /slurm/home/zju/zhanglab/yangchentao/miniconda3/bin/activate tidk
for asm in verkko hifiasm
do
	samtools faidx ${ID}_${HAP}.${asm}.small_contig.fasta
	python3 $src/makeChrEndBed.py ${ID}_${HAP}.${asm}.small_contig.fasta.fai 5000 > ${ID}_${HAP}.${asm}.small_contig.end.bed
	tidk search  --fasta ${ID}_${HAP}.${asm}.small_contig.fasta  --string  TTAGGG --output ${ID}_${HAP}.${asm} --dir ./ -w 120
	python3 /slurm/home/zju/zhanglab/yangchentao/projects/AsianPan/pipeline/GapFill/tidk2teloRegion.py ${ID}_${HAP}.${asm}_telomeric_repeat_windows.csv 0.6 > ${ID}_${HAP}.${asm}.telomere_100_0.6.bed
	bedtools coverage -a ${ID}_${HAP}.${asm}.small_contig.end.bed -b ${ID}_${HAP}.${asm}.telomere_100_0.6.bed |awk '$8>0.6' |cut -f 1,4 |sort -k1,1V -k2n > ${ID}_${HAP}.${asm}.small_contig.is_telomere.txt
	if [ -s ${ID}_${HAP}.${asm}.small_contig.is_telomere.txt ];then
		cut -f 1 ${ID}_${HAP}.${asm}.small_contig.is_telomere.txt > ${ID}_${HAP}.${asm}.small_contig.is_telomere.ids
		$src/fastaKit -nl ${ID}_${HAP}.${asm}.small_contig.is_telomere.ids -o ${ID}_${HAP}.${asm}.small_contig.is_telomere.fasta ${ID}_${HAP}.${asm}.small_contig.fasta
		$src/unimap -cx asm10 ${CHM13_END} ${ID}_${HAP}.${asm}.small_contig.is_telomere.fasta > ${ID}_${HAP}.${asm}.small_contig.is_telomere.map2chm13.paf
	else
		echo "No telomeric sequence found in ${asm} assembly"
	fi
done

