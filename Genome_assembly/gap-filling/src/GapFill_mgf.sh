if [[ $# != 4   ]] ; then
	echo -e "Pipeline:\n\tfill simple gaps which are covered by spanning long reads," 
	echo -e "\tsearch telomere and trim potential misassemblies at the edge of chromosomes"
	echo -e "\tfinally, mappint to chm13 to check structure of chromosome\n"
	echo "Usage : $0 prefix(sampleID) hap[Mat|pat] ont2asm.sort.bam draft.fasta"
	exit 1
fi

id=$1
hap=$2
bam=$3
draft=$4

src=$(cd $(dirname $0);pwd)
wk=`pwd`

echo "[INFO]: $id"
bam=$(realpath $bam)
echo "[INFO]: bam is: $bam"
scaf=$(realpath $draft)
echo "[INFO]: scaf is: $scaf"

# CONFIGURE OF DATA, SOFTWARE..
if [ -s $src/init.conf  ]; then
	echo "Loading configure from $src/init.conf"
	source $src/init.conf
else
	echo "Can not assess to init.conf in $src"
	exit -1
fi


###########################################################
################### extract gap ###########################
###########################################################
# extend the gap region 
if [ ! -e ${draft}.gaps.ext.maps ]; then
	date && echo "[INFO]: extend the gap region"
	[ -e ${draft}.fai ] || samtools faidx ${draft}
	awk '{print $1"\t"$2}' ${draft}.fai > ${draft}.gsize.txt
	# -b, both sides, extend 20kb
	perl $src/../common/gap2posBed.pl ${draft} > ${draft}.gaps.bed
	bedtools slop -b 20000 -i ${draft}.gaps.bed -g ${draft}.gsize.txt > ${draft}.gaps.ext.bed
	# bedtools slop -b 0.5 -pct -i ${draft}.gaps -g ${draft}.gsize.txt > ${draft}.gaps.ext.bed
	paste ${draft}.gaps.bed ${draft}.gaps.ext.bed > ${draft}.gaps.ext.maps
	date && echo "[INFO]: extend gap done"
else
	date && echo "[INFO]: extend gap already done"
fi

###########################################################
##################### Bamsnap #############################
###########################################################
[ -d bamsnap ] || mkdir bamsnap
[ -e $bam.bai ] || samtools index $bam
if [ ! -e bamsnap/bamsnap.finish ];then
	date && echo "[INFO]: extract bam around gaps to bamsnap/ ..."
	cat ${draft}.gaps.ext.maps|while read chr gaps gape c start end
	do
		# get bam for each gap
		samtools view -bh -F 256  $bam $chr:$start-$end > bamsnap/${chr}_$gaps-$gape.bam
		samtools index bamsnap/${chr}_$gaps-$gape.bam
		# bamsnap
		echo -e "[INFO]: ploting the gap of $chr\t$gaps\t$gape"
		/slurm/home/zju/zhanglab/zhouyang/software/miniconda3.backup/bin/bamsnap  -bam bamsnap/${chr}_$gaps-$gape.bam -ref ${draft} -title "Gap of ${chr}_$gaps-$gape"  -pos ${chr}:$gaps-$gape -margin 100 -draw coordinates bamplot base -out bamsnap/${chr}_$gaps-$gape.png -read_group strand && touch bamsnap/bamsnap.finish
	done
	date && echo "[INFO]: extract bam around gaps to bamsnap/ done"
else
	date && echo "[INFO]: extract bam around gaps to bamsnap/ already done"
fi

###########################################################
#################### jbrowse2 #############################
###########################################################
# prepare conf for jbrowse2
[ -d jbrowse2 ] || mkdir jbrowse2
if [ ! -e jbrowse2.tgz ]; then
	date && echo "[INFO]: prepare conf for jbrowse2..."
	cut -f 1 ${draft}.gaps.bed|sort |uniq > jbrowse2/contain_gaps.chrs.list
	$src/../common/fastaKit -nl jbrowse2/contain_gaps.chrs.list -o jbrowse2/contain_gaps.chrs.fasta ${draft}
	samtools faidx jbrowse2/contain_gaps.chrs.fasta
	samtools merge jbrowse2/contain_gaps.bam bamsnap/*.bam 
	samtools index jbrowse2/contain_gaps.bam
	tar czf jbrowse2.tgz jbrowse2/
	date && echo "[INFO]: jbrowse2 files done"
else
	date && echo "[INFO]: jbrowse2 files already done"
fi

###########################################################
#################### yagcloser ############################
###########################################################
# fill gaps based on spanning long reads using YAGCloser, note: this can only close several simple gaps
[ -d yagcloser ] || mkdir yagcloser
cd yagcloser
if [ ! -e yagcloser.finish ];then
	date && echo "[INFO]: fill simple gaps using yagcloser ..."
	$src/detgaps $scaf >gaps.bed
	python3 $src/yagcloser.py -g ../${draft} -a ../jbrowse2/contain_gaps.bam -b gaps.bed -o output -pld 0.15 -f 100 -mins 2 -s ${id}_${hap}
	if [ -e output/${id}_${hap}.edits.txt ]; then
		filled_gaps=`wc -l output/${id}_${hap}.edits.txt`
		echo "[INFO]: there are $filled_gaps can be filled in this process"
		python3 $src/update_assembly_edits_and_breaks.py -i ../${draft} -o ${id}_${hap}.v2.fasta -e output/${id}_${hap}.edits.txt && touch yagcloser.finish
	else
		echo "[INFO]: there is no one gap can be filled in this process"
		ln -s ../${draft} ${id}_${hap}.v2.fasta && touch yagcloser.finish
	fi

	date && echo "[INFO]: fill simple gaps using yagcloser done"
else
	date && echo "[INFO]: fill simple gaps using yagcloser already done"
fi

cd ..

###########################################################
#################### TELOMERE #############################
###########################################################
# check telomere
date && echo "[INFO]: dealing with telomere..."
[ -d telomere ] || mkdir telomere
cd telomere

[ -e ${id}_${hap}.v2.fasta ] || ln -s ../yagcloser/${id}_${hap}.v2.fasta
sh  $src/telomere_identify_shell.sh ${id} ${hap} ${id}_${hap}.v2.fasta v2 >tidk.v2.sh
if [ ! -s ${id}_${hap}.v2.telomere.200_0.5_m300.bed ]; then
	sh tidk.v2.sh
	if [ -s ${id}_${hap}.v2.telomere.200_0.5_m300.bed ];then
		echo "[INFO]: v2 telomere identifing done"
	else
		echo "[ERROR]: something wrong in v2 telomere identifing process"
		exit 1
	fi
else
	echo "[INFO]:  v2 telomere identifing already done"
fi

if [ ! -s ${id}_${hap}.v3.fasta ]; then
	sh $src/telomere_errorTrim_shell.sh ${id} ${hap}  ${id}_${hap}.v2.fasta ${id}_${hap}.v2.telomere.200_0.5_m300.bed ${id}_${hap}.v3.fasta  > telomere_errorTrim.sh
	sh telomere_errorTrim.sh
	if [ -s ${id}_${hap}.v3.fasta ];then
		echo "[INFO]: Telomere Triming done"
		# remove small contigs
		python3 $src/../telomere/removeunAnchored.py ${id}_${hap}.v3.fasta ${id}_${hap}.v3
		samtools faidx ${id}_${hap}.v3.chr.fasta 
		python3 $src/../telomere/makeChrEndBed.py ${id}_${hap}.v3.chr.fasta.fai 1000 > ${id}_${hap}.v3.chr.fasta.end.bed
	else
		echo "[ERROR]: something wrong in Telomere Triming process"
		exit 1
	fi

else
	date && echo "[INFO]: Telomere Trimed already done"
fi


if [ ! -s ${id}_${hap}.v3.telomere.200_0.5_m300.bed ]; then
	# detect missing telomere of ${id}_${hap}.v3.chr.fasta
	sh  $src/telomere_identify_shell.sh ${id} ${hap} ${id}_${hap}.v3.chr.fasta v3 >tidk.v3.sh
	sh tidk.v3.sh
	if [ -s  ${id}_${hap}.v3.telomere_200_0.5.bed ]; then
		# if the telomere sequence coverage less than 0.5, set it as missing
		bedtools coverage -a ${id}_${hap}.v3.chr.fasta.end.bed -b ${id}_${hap}.v3.telomere_200_0.5.bed |awk '$8<0.5' |cut -f 1,4 |sort -k1,1V -k2n > ${id}_${hap}.v3.chr.fasta.teloMiss.txt
	else
		echo "[ERROR]: something wrong in teloMiss detecting process"
		exit 1
	fi

else
	echo "[INFO]: v3 telomere identifing already done"
fi

cd ..

<<REMOVED
#########################################################
######################### nextGap #######################
#########################################################
[ -d nextGap  ] || mkdir nextGap
cd nextGap
if [ ! -e nextGap.finish ];then
	date && echo "[INFO]: nextGap starting"
	[ -e genome.fasta  ] || ln -s ../telomere/${id}_${hap}.v3.chr.fasta ./genome.fasta
	[ -e ${id}_${hap}-unknown_ONT.sort.bam  ] || ln -s ../${id}_${hap}-unknown_ONT.sort.bam
	[ -e ${id}_${hap}-unknown_ONT.sort.bam.bai  ] || ln -s ../${id}_${hap}-unknown_ONT.sort.bam.bai
	# input ngs
	ls ${DATA}/NGS/${id}-01/*.clean.fq.gz > ngs.list
	# input long reads
	echo "${DATA}/Nanopore/${id}-01/binning/haplotype/haplotype-${hap}.fasta.gz" > longread.list
	echo "${DATA}/Nanopore/${id}-01/binning/haplotype/haplotype-unknown.fasta.gz" >> longread.list
	# this will generate shell, ${id}_${hap}.ng.sh, and then run it
	sh $src/nextGap_shell.sh ${id} ${hap} && ${SJM} -c 48 -m 400g  -t 600 ${id}_${hap}.ng.sh
	if [ -s output/output/asm.gap.closed.fa ]; then
		touch nextGap.finish
		date && echo "[INFO]: nextGap finished"
	else
		echo "[ERROR]: nextGap has no result, please check!"
		exit -1
	fi
fi
cd ..
REMOVED

#########################################################
####################### MGF #############################
#########################################################
[ -d MGF ] || mkdir MGF
cd MGF
## QV
[ -d QV ] || mkdir QV
cd QV
[ -e genome.fasta ] || ln -s ../../telomere/${id}_${hap}.v3.chr.fasta ./genome.fasta
if [ ! -e qv.finish ]; then
	$src/meryl_qv_shell.sh ${id} ${MERYL_DB}/hybrid/${id}/${id}.hybrid.meryl genome.fasta ${id}_hybrid > qv.sh && ${SJM} -c 48 -m 20g  -t 100 qv.sh
else
	date && echo "[INFO]: QV already done"
fi
cd ..
## map to reference to check structure
[ -d SCHECK ] || mkdir SCHECK
cd SCHECK
if [ ! -e scheck.finish ];then
	date && echo "[INFO]: SCHECK starting"
	[ -e genome.fasta ] || ln -s ../../telomere/${id}_${hap}.v3.chr.fasta ./genome.fasta
	echo -e "#!/bin/bash\n#SBATCH --cpus-per-task=24\n#SBATCH -p ${SGE_PARTITION}\n#SBATCH --mem=35g\n"  > ${id}_${hap}.scheck.sh 
	echo "sh $src/structure_check.sh  ${id}_${hap}  genome.fasta ${REFERENCE} 24 && touch scheck.finish" >> ${id}_${hap}.scheck.sh
	${SJM} -c 24 -m 35g -t 300 ${id}_${hap}.scheck.sh
	date && echo "[INFO]: SCHECK done"
else
	date && echo "[INFO]: SCHECK already done"
fi
cd ..

## get imperfect mapping reads, and construct local assembly graph
[ -d MANUAL_FILL ] || mkdir MANUAL_FILL
cd MANUAL_FILL
[ -e genome.fasta  ] || ln -s ../../telomere/${id}_${hap}.v3.chr.fasta ./genome.fasta
if [ -e mapping.finish  ]; then
	# pass
	date && echo "mapping already done"
else
	if [ ! -s $wk/repetitive_k15.txt  ];then
		meryl count k=15 output merylDB genome.fasta
		meryl print greater-than distinct=0.9998 merylDB > repetitive_k15.txt && rm -r merylDB
	fi
	sh $src/ont_mapping.sh  ${id} ${hap} genome.fasta && ${SJM} -t 300 -m 50g -c 48 ont_mapping.sh
	if [ -s out2asm.ont.bam.bai ];then
		touch mapping.finish
	else
		echo "[ERROR]: something wrong in mapping process, please check"
		exit 1
	fi
fi

# get unmapped reads and clipped reads
if [ ! -e get_reads.finish  ]; then
	sh $src/get_BadMapRead_shell.sh ${id} out2asm.ont.bam > get_BadMapRead.sh && ${SJM} -t 100 -m 5g -c 8 get_BadMapRead.sh
	if [ -s imperfect_mapped.ont.fa ]; then
		touch get_reads.finish
	else
		echo "[ERROR]: something wrong in get_BadMapRead, please check"
		exit 1
	fi
else
	echo "[INFO]: get_BadMapRead already done"
fi

# all vs all alignment
if [ ! -e all_vs_all.finish  ]; then
	[ -s genome.fasta.fai ] || samtools faidx genome.fasta
	perl $src/../common/gap2posBed.pl genome.fasta > genome.fasta.gap.bed
	if [ -s genome.fasta.gap.bed ];then
		# it has gaps
		python3 $src/cutGap2reads.py genome.fasta.fai genome.fasta.gap.bed > genome.fasta.gap.slop2read.fa
		cat genome.fasta.gap.slop2read.fa >> imperfect_mapped.ont.fa
		sh $src/ont_allvsall_shell.sh imperfect_mapped.ont.fa  > ont_allvsall.sh && ${SJM} -t 100 -m 100g -c 24 ont_allvsall.sh
		if [ -s imperfect_read2read.paf ]; then
			touch all_vs_all.finish
		else
			echo "[ERROR]: something wrong in all_vs_all, please check"
			exit 1
		fi
	else
		echo "[INFO]: there is no gap in ${id} ${hap}"
		exit 0
	fi
else
	echo "[INFO]: all_vs_all already done"
fi


cd ..

cd ..
