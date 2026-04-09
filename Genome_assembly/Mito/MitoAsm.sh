# mitogenome
ls |grep '^[CK]' |while read a
do
	if [ -e ${a}/Mat/telomere/${a}_Mat.v3.chr.fasta ] && [ -e ${a}/Pat/telomere/${a}_Pat.v3.chr.fasta ]; then
		echo $a
	fi
done > assembly.both_done.list

# this will submit hifi mapping or mitoz
sh /share/home/zhanglab/user/yangchentao/projects/AsianPan/pipeline/Mito/mitoFound.sh assembly.both_done.list >  mito.log

# check hifi mapping result
grep none mito.log|awk '{print $1}' |while read a; do awk '$10>15000 && $10/$11>0.9' $a/Mito/hifi2mito.paf|sort -k8n |wc -l ;done

# if got hifi reads for mitogenome assembly, then try it
grep none mito.log|awk '{print $1}' |while read id
do
	cd $id/Mito
	num=`awk '$10>15000 && $10/$11>0.9' hifi2mito.paf|sort -k8n |wc -l `
	if [ $num -gt 2 ];then
		echo "$id"
		sh /share/home/zhanglab/user/yangchentao/projects/AsianPan/pipeline/Mito/mito_asm_hifi.sh $id hifi2mito.paf
		sbatch -e hifiAsmMito.sh.e -o hifiAsmMito.sh.o hifiAsmMito.sh
	fi
	cd ../..
done


# waiting mitoz done
src=/share/home/zhanglab/user/yangchentao/projects/AsianPan/pipeline/Mito
MITO_REF=/share/home/zhanglab/user/yangchentao/projects/AsianPan/pipeline/Mito/NC_012920.1.fasta
cat mitoz.list |while read id
do
	cd $id/Mito
	ln -s $id.result/$id.megahit.result/$id.megahit.mitogenome.fa ./$id.mitogenome.fasta
	minimap2 -t 2 -cx asm5 $MITO_REF $id.mitogenome.fasta > ori2ref.paf
	python3 $src/MitoCutter.py $id.mitogenome.fasta ori2ref.paf $id.mitogenome.final
	minimap2 -t 2 -cx asm5 --cs $MITO_REF $id.mitogenome.final.fasta > final2ref.paf
	python3 $src/LINKVIEW.py -t 3  --svg_width 1500 --svg_height 400 --label_font_size 11 --label_angle 30 --chro_axis  --svg2png_dpi 600 --no_dash   -o $id.mitogenome.final final2ref.paf

	cd ../..
done
