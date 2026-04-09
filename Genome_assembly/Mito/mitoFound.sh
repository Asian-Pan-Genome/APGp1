#!/bin/bash
if [[ $# != 1 ]];then
	echo  "Usage: sh $0  current_done"
	exit 1
fi
list=$1
cat $list|awk -F "/" '{print $1}' |sort |uniq -c |awk '$1==2{print $2}' > both_done.list

wk=`pwd`
src=$(cd $(dirname $0);pwd)
source /share/home/zhanglab/user/yangchentao/projects/AsianPan/pipeline/Mito/init.conf

# get list, visOri.list
cat both_done.list|while read ID
do
	cd $ID
	if [ -s Mito/$ID.mitogenome.final.fasta ];then
		echo "$ID already done"
		cd $wk && continue
	fi
	if [ -d Mat ] && [ -d Pat ];then
		# if both already, then going on
		#echo "$ID MAT and Pat both already"
		[ -d Mito ] || mkdir Mito
		if [ -s Mat/telomere/${ID}_Mat.v3.mitogenome.fa ] && [ ! -s Pat/telomere/${ID}_Pat.v3.mitogenome.fa ];then
			echo "$ID mitogenome is assigned to Mat"
			cp Mat/telomere/${ID}_Mat.v3.mitogenome.fa Mito/$ID.mitogenome.fasta
			size=`wc -c Mito/$ID.mitogenome.fasta|awk '{print $1}'`
			if [ $size -lt  17000 ]; then
				echo "$ID is one-copy"
			elif [ $size -gt 17000 ];then
				echo "$ID is more than one copy"
			fi
		elif [ ! -s Mat/telomere/${ID}_Mat.v3.mitogenome.fa ] && [ -s Pat/telomere/${ID}_Pat.v3.mitogenome.fa ];then
			echo "$ID mitogenome is assigned to Pat"
			cp Pat/telomere/${ID}_Pat.v3.mitogenome.fa Mito/$ID.mitogenome.fasta
			size=`wc -c Mito/$ID.mitogenome.fasta|awk '{print $1}'`
			if [ $size -lt  17000 ]; then
				echo "$ID is one-copy"
			elif [ $size -gt 17000 ];then
				echo "$ID is more than one copy"
			fi
		elif [ -s Mat/telomere/${ID}_Mat.v3.mitogenome.fa ] && [ -s Pat/telomere/${ID}_Pat.v3.mitogenome.fa  ];then
			echo "$ID mitogenome is both assigned to Mat and Pat"
			md5_mat=`md5sum Mat/telomere/${ID}_Mat.v3.mitogenome.fa|awk '{print $1}'`
			md5_pat=`md5sum Pat/telomere/${ID}_Pat.v3.mitogenome.fa|awk '{print $1}'`
			if [ $md5_mat == $md5_pat ];then
				cp Mat/telomere/${ID}_Mat.v3.mitogenome.fa Mito/$ID.mitogenome.fasta
				echo "$ID has Mat and Pat two copies, they are same, so remove pat..."
			else
				cp Mat/telomere/${ID}_Mat.v3.mitogenome.fa Mito/$ID.mitogenome.fasta
				cp Pat/telomere/${ID}_Pat.v3.mitogenome.fa Mito/${ID}.alt.mitogenome.fa
				echo "$ID has Mat and Pat two copies, they are not same, so keep pat as alt..."
			fi
		else
			echo "$ID has none"
			
		fi
		if [ -s Mito/$ID.mitogenome.fasta ]; then
			cd Mito
			minimap2 -t 2 -cx asm5 $MITO_REF $ID.mitogenome.fasta > ori2ref.paf
			python3 $src/mito_cutter.py $ID.mitogenome.fasta ori2ref.paf $ID.mitogenome.final 
			minimap2 -t 2 -cx asm5 --cs $MITO_REF $ID.mitogenome.final.fasta > final2ref.paf
			#$R ${DOTPLOT_R} -m 100 -s -f -p 20 -o $ID.mitogenome.final.dotplot final2ref.paf 1>plot.log
			python3 $src/LINKVIEW.py -t 3  --svg_width 1500 --svg_height 400 --label_font_size 11 --label_angle 30 --chro_axis  --svg2png_dpi 600 --no_dash   -o $ID.mitogenome.final final2ref.paf
			cd ..
		fi
	else
		echo "$ID not already"
	fi

	cd $wk
done

