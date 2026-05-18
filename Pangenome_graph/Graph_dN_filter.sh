#!/usr/bin/sh
#SBATCH --job-name=d54
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -p cpu128
#SBATCH --cpus-per-task=32
#SBATCH -t 500:00:00
#SBATCH --mem=2000g
#SBATCH --mail-type=ALL
#SBATCH --mail-user=3210105396@zju.edu.cn

date

dN=54
thread=32

for name in $(ls ./APGp1-HPRCp1-HGSVCp3_MC_CN1v1.chroms/*)
do
	echo $name
	pref=$(basename $name | cut -d '.' -f 1 )
	vg clip -d $dN -m 1000 -P "CN1v1#0#" -t $thread -v $name > $pref".d"$dN".vg"
	vg clip -s -P "CN1v1#0#" -t $thread -v $pref".d"$dN".vg" > $pref".d"$dN".rmStub.vg"
	rm $pref".d"$dN".vg"
	date
	echo "Finish "$pref"!" 
done

vg combine $(for i in `ls *.vg`;do echo " ${i} ";done) > merge.vg
date
echo "Finish combine!"

# rm *.rmStub.vg

vg view --threads $thread merge.vg > merge.gfa
date
echo "Finish convert to gfa from vg"

vg gbwt -G merge.gfa --gbz-format -g merge.gbz
date
echo "Finish convert to gbz from gfa"
