#!/bin/sh
#SBATCH --job-name=vkC139_100k
#SBATCH --partition=cpu64,cpu128,gpu4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=420g
#SBATCH --time=900:00:00

threads=50
mem=420
famID="C139-CBY01"

date

##build specific k-mer db
hapmers.sh /share/home/project/zhanglab/APG/NGS/${famID}-02/2.meryl /share/home/project/zhanglab/APG/NGS/${famID}-03/3.meryl /share/home/project/zhanglab/APG/NGS/${famID}-01/1.meryl

date

##verkko run
hifi=`ls /share/home/project/zhanglab/APG/HiFi/${famID}-01/*.filt.fastq.gz |xargs`
ont=`ls /share/home/project/zhanglab/APG/ONT/${famID}-01/*pass_100k.fastq.gz |xargs`

dir='verkko'

time verkko -d $dir \
--hifi $hifi \
--nano $ont \
--threads ${threads} \
--hap-kmers 2.hapmer.meryl 3.hapmer.meryl trio \
--local-memory ${mem} \
--sto-run ${threads} ${mem} 24 \
--mer-run ${threads} ${mem} 24 \
--ovb-run ${threads} ${mem} 24 \
--red-run ${threads} ${mem} 24 \
--mbg-run ${threads} ${mem} 24 \
--utg-run ${threads} ${mem} 24 \
--spl-run ${threads} ${mem} 24 \
--ali-run ${threads} ${mem} 24 \
--pop-run ${threads} ${mem} 24 \
--utp-run ${threads} ${mem} 24 \
--lay-run ${threads} ${mem} 24 \
--sub-run ${threads} ${mem} 24 \
--par-run ${threads} ${mem} 24 \
--cns-run ${threads} ${mem} 24

echo "verkko done!"
date

###statistic and synteny plot

yak2="/share/home/project/zhanglab/APG/NGS/${famID}-02/2.yak"
yak3="/share/home/project/zhanglab/APG/NGS/${famID}-03/3.yak"

for i in `ls ${dir}/| grep "fasta" | grep "haplotype"|perl -npe "s/.fasta//"`;
do
echo $dir/${i} ;
N50 $dir/${i}.fasta $dir/$famID"_"${i}.n50 10000 ;
cat $dir/${i}.fasta | seqkit fx2tab | cut -f 2 | sed -r 's/n+/\n/gi'  | cat -n | seqkit tab2fx | seqkit replace -p "(.+)" -r "Contig{nr}" > $dir/${famID}_${i}_contig.fasta
yak trioeval ${yak2} ${yak3} $dir/${famID}_${i}_contig.fasta -t ${threads} > $dir/$famID"_"${i}.ye
echo "print Synteny for ${i}!"
sh /share/home/zhanglab/user/wudongya/software/unimap_plot/run_unimap_dotplot.sh /share/home/project/zhanglab/APG/Reference/CHM13v2m.fasta $dir/${famID}_${i}_contig.fasta $dir/${famID}"_"${i} ;
done

<<EOF
rm -rf 1*
rm -rf 2*
rm -rf 3*
rm -rf read.only.meryl
rm -rf shrd*
rm -f cutoffs.txt
rm -f inherited_hapmers.hist
rm -rf ${dir}/1-buildGraph
rm -rf ${dir}/2-processGraph
rm -rf ${dir}/3-align
rm -rf ${dir}/4-processONT
rm -rf ${dir}/5-untip
rm -rf ${dir}/6-layoutContigs
rm -rf ${dir}/6-rukki
rm -rf ${dir}/7-consensus
EOF

date
