#!/bin/sh
#SBATCH --job-name=R5_C139
#SBATCH --partition=cpu64
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=420g
#SBATCH --time=900:00:00

date

threads=50
famID="C139-CBY01"
hifi=`ls /share/home/project/zhanglab/APG/HiFi/${famID}-01/*.filt.fastq.gz |xargs`
ont=`ls /share/home/project/zhanglab/APG/ONT/${famID}-01/*pass_100k.fastq.gz |xargs | sed "s/ /,/g"`
h1=`ls /share/home/project/zhanglab/APG/HiC/${famID}-01/*_1.clean.fq.gz |xargs | sed "s/ /,/g"`
h2=`ls /share/home/project/zhanglab/APG/HiC/${famID}-01/*_2.clean.fq.gz |xargs | sed "s/ /,/g"`
yak2="/share/home/project/zhanglab/APG/NGS/${famID}-02/2.yak"
yak3="/share/home/project/zhanglab/APG/NGS/${famID}-03/3.yak"

echo `hifiasm --version`
echo $famID
echo $hifi
echo $ont
echo $h1
echo $h2

hifiasm --h1 ${h1} --h2 ${h2} -o ${famID}_hifiasm_hic_ont -t ${threads} --ul ${ont} ${hifi}

echo "hifiasm_hic_ont done!"
date

rm *bin

for i in `ls | grep "p_ctg.gfa" | perl -npe "s/.p_ctg.gfa//"`; do awk '/^S/{print ">"$2"\n"$3}' ${i}.p_ctg.gfa | fold > ${i}_ctg.fa ; N50 ${i}_ctg.fa ${i}_ctg.n50 10000 ; done
for i in `ls | grep "p_ctg.gfa" | perl -npe "s/.p_ctg.gfa//"`; do yak trioeval ${yak2} ${yak3} ${i}_ctg.fa > ${i}_ctg.ye ; done

echo "TrioC\n"
perl /share/home/project/zhanglab/APG/Assembly/R5a_correct_trioReassign.pl ${famID}
echo "TrioC finished!\n"
