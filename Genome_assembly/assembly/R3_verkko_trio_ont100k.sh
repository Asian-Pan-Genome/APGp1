#!/bin/sh
#SBATCH --job-name=verkko
#SBATCH --partition=all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=420g
#SBATCH --time=900:00:00

threads=30
famID="XXX"

date

##build specific k-mer db
hapmers.sh /YOUR_PATH/NGS/${famID}-02/2.meryl /YOUR_PATH/NGS/${famID}-03/3.meryl /YOUR_PATH/NGS/${famID}-01/1.meryl

##hifi
hifi=`ls /YOUR_PATH/HiFi/${famID}-01/*.filt.fastq.gz |xargs`
##ONT(ultra-long, >100kb)
ont=`ls /YOUR_PATH/Nanopore/${famID}-01/*pass_100k.fastq.gz |xargs`

dir='verkko'

##verkko v2.0 requires Graphaligner >=1.0.19

time verkko -d $dir \
--hifi $hifi \
--nano $ont \
--threads ${threads} \
--hap-kmers 2.hapmer.meryl 3.hapmer.meryl trio \
--local-memory 420 \
--sto-run ${threads} 420 24 \
--mer-run ${threads} 420 24 \
--ovb-run ${threads} 420 24 \
--red-run ${threads} 420 24 \
--mbg-run ${threads} 420 24 \
--utg-run ${threads} 420 24 \
--spl-run ${threads} 420 24 \
--ali-run ${threads} 420 24 \
--pop-run ${threads} 420 24 \
--utp-run ${threads} 420 24 \
--lay-run ${threads} 420 24 \
--sub-run ${threads} 420 24 \
--par-run ${threads} 420 24 \
--cns-run ${threads} 420 24

echo "verkko done!"
date

###SER
yak2="/YOUR_PATH/NGS/${famID}-02/2.yak"
yak3="/YOUR_PATH/NGS/${famID}-03/3.yak"

###SYNTENY
for i in `ls ${dir}/ | grep "fasta" | grep "haplotype" | perl -npe "s/.fasta//"`;
do
echo $dir/${i} ;
N50 $dir/${i}.fasta $dir/$famID"_"${i}.n50 10000 ;
cat $dir/${i}.fasta | seqkit fx2tab | cut -f 2 | sed -r 's/n+/\n/gi'  | cat -n | seqkit tab2fx | seqkit replace -p "(.+)" -r "Contig{nr}" > $dir/${famID}_${i}_contig.fasta
yak trioeval ${yak2} ${yak3} $dir/${famID}_${i}_contig.fasta -t ${threads} > $dir/$famID"_"${i}.ye
echo "print Syntent for ${i}!"
###CHM13v2 as reference
ref="/YOUR_PATH/CHM13v2m.fasta"
sh /YOUR_PATH/software/unimap/run_unimap_dotplot.sh ${ref} $dir/${famID}_${i}_contig.fasta $dir/${famID}"_"${i} ;
done

rm -rf 1* 2* 3*
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

date
