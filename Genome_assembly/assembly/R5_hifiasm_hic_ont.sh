#!/bin/sh
#SBATCH --job-name=R5_C019
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100g
#SBATCH --time=900:00:00

date

threads=10
famID="C019-CHA-E19"
hifi=`ls /YOUR_PATH/PB/CCS/${famID}-01/*.filt.fastq.gz |xargs`
ont=`ls /YOUR_PATH/Nanopore/${famID}-01/*pass_100k.fastq.gz |xargs | sed "s/ /,/g"`
h1=`ls /YOUR_PATH/HiC/${famID}-01/*_1.clean.fq.gz |xargs | sed "s/ /,/g"`
h2=`ls /YOUR_PATH/HiC/${famID}-01/*_2.clean.fq.gz |xargs | sed "s/ /,/g"`
yak2="/YOUR_PATH/NGS/${famID}-02/2update.yak"
yak3="/YOUR_PATH/NGS/${famID}-03/3update.yak"

echo `hifiasm --version`
echo $famID
echo $hifi
echo $ont
echo $h1
echo $h2

/YOUR_PATH/software/anaconda/bin/hifiasm --h1 ${h1} --h2 ${h2} -o ${famID}_hifiasm_hic_ont -t ${threads} --ul ${ont} ${hifi}

echo "hifiasm_hic_ont done!"
date

rm *bin

for i in `ls | grep "p_ctg.gfa" | perl -npe "s/.p_ctg.gfa//"`; do awk '/^S/{print ">"$2"\n"$3}' ${i}.p_ctg.gfa | fold > ${i}_ctg.fa ; N50 ${i}_ctg.fa ${i}_ctg.n50 10000 ; done
for i in `ls | grep "p_ctg.gfa" | perl -npe "s/.p_ctg.gfa//"`; do yak trioeval ${yak2} ${yak3} ${i}_ctg.fa > ${i}_ctg.ye ; done

echo "TrioC\n"
perl /YOUR_PATH/script/R5a_correct_trioReassign.pl ${famID}
echo "TrioC finished!\n"
