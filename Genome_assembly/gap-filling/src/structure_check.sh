#!/bin/bash

if [[ $# != 4  ]]; then
	echo "[LOCAL]"
	echo "Usage: sh $0 ID_[MAT|PAT] DRAFT REF THREADS"
	exit 1
fi

# values
ID=$1
DRAFT=`realpath $2`
REF=$3
THREADS=$4

src=$(cd $(dirname $0);pwd)
ref_dir=$(dirname $REF)
highlight=${src}/highlight.txt

source $src/init.conf

echo "ID = ${ID}"
echo "Draft genome = ${DRAFT}"
echo "REF = ${REF}"
echo "THREADS = ${THREADS}"

if [ -e $ref_dir/chm13v2.0.repetitive_k19.txt ]; then
	repeat_index="$ref_dir/chm13v2.0.repetitive_k19.txt"
else
	echo -e "[ERROR]: Can not find the repeate index for $REF"
	exit 1
fi

if [ ! -e $highlight ]; then
	echo "[ERROR]: Can not find highlight.txt from $src"
	exit 1
fi

# mapping draft genome to CHM13 
echo "[INFO]: mapping to chm13 to check structure"
# mapping
echo "[INFO]: Winnowmap map starting..."
winnowmap -t ${THREADS} -W $repeat_index -cx asm10 --cs ${REF}  ${DRAFT} > ${ID}.map2ref.paf
python3 $src/alignmentStatFromPaf.py ${ID}.map2ref.paf > ${ID}.map2ref.paf.stat
echo "[INFO]: Winnowmap map done"

#assign paf by chrs
# report error when no matched chr
grep "^chr" ${ID}.map2ref.paf.stat|sort -k1,1V | awk 'NF < 3' >err.list
if [ -s err.list ];then
	echo "[ERROR]: some chromosomes are not able to map to reference, see => err.list"
fi

grep "^chr" ${ID}.map2ref.paf.stat|sort -k1,1V|awk 'NF > 3' | while read qry qlen chr reflen cov iden
do
	# generate karyotype file
	[ -d $chr ] || mkdir $chr
	cd $chr
	# extract paf
	awk -v a=$qry -v b=$chr '$1==a && $6==b' ../${ID}.map2ref.paf | sort -k6,6V -k8n > $chr.paf
	if [ -s $chr.paf ];then
		echo "[INFO]: $chr looks good"
		python3 $src/MakeLinkViewKaryotypeFromPaf.py $chr.paf $chr > karyotype.txt
		# linkview
		if [ -s karyotype.txt ];then
			python3 $src/LINKVIEW.py -t 3 -k karyotype.txt --svg_width 1800 --svg_height 600 --label_font_size 12 --label_angle 40 --chro_axis --gap_length 0.01 --svg2png_dpi 600 --no_dash  -hl $highlight $chr.paf 
			mv linkview_output.svg $chr.linkview.svg
			mv linkview_output.png $chr.linkview.png
			# dotplot
			$R ${DOTPLOT_R} -m 5000 -s -f -p 20 -o $chr.dotplot.pdf $chr.paf 1>plot.log
		else
			echo "[WARNING]: karyotype.txt or $chr.hybrid.paf is empty!"
		fi
	else
		echo "[WARNING]: $chr has no alignments"
	fi
	cd ..
done
