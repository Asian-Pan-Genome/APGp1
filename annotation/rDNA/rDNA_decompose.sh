#!/bin/bash
date
#Get the 45S coding regions in the assembly by blastn.
blastn -db ${rdna_db}/rb -query ${assembly}.rdna.fa -out rDNA.rb.tbl -outfmt 6 -num_threads 1 -gapopen 3 -gapextend 1 
awk '($9 < $10 && $9-1 <= 10 && 13332-$10 <= 10) || ($9 >= $10 && $10-1 <= 10 && 13332-$9 <= 10)' rDNA.rb.tbl > rDNA.rb.pure.tbl
sed -e 's/:/\t/1' rDNA.rb.pure.tbl | awk 'OFS="\t" {gsub("-","\t",$2)}1' | awk 'OFS="\t"{ print $1,$2+$9-1,$2+$10}' > rDNA.rb.pure.bed

#Get the rDNA unit coordinates from the coordinate of the 45S coding region.
python3 to_decomp.py -bed rDNA.rb.tbl -tol 300 | sed -e 's/:/\t/1' | awk 'OFS="\t" {gsub("-","\t",$2)}1' |awk 'OFS="\t"{print $1,$2+$4,$2+$5,$6"_"NR,$7,$8}' > rDNA.decomp.r1.bed
#Get the rDNA unit flanking the rDNA array.
bedtools subtract -a ${assembly}.rdna.bed -b rDNA.decomp.r1.bed | awk 'OFS="\t"{print $1,$2,$3,"rDNA","0","na"}' | awk '$3-$2 < 40000' > rDNA.decomp.true_r2.bed
python3 cutbyBed.py -fasta ${assembly}.fa -bed rDNA.decomp.true_r2.bed > rDNA.decomp.true_r2.fasta
minimap2 -xasm20 -c -t 1 ${human_rdna_reference}.fa rDNA.decomp.true_r2.fasta > direction.paf
awk '{print $10/$11"\t"$0}' direction.paf | sort -k2,2 -k1,1n -k12,12n | awk '{if (chr!=$2){print $2"\t"$6; chr=$2}}' | sed -e 's/:/\t/1' | awk 'OFS="\t" {gsub("-","\t",$2)}1' | awk 'OFS="\t"{print $1,$2,$3,"rDNA","0",$4}' > rDNA.decomp.true_r2.dic.bed

#Fix the rDNA unit that has mutiple coding region annotation.
bedtools subtract -a ${assembly}.rdna.bed -b rDNA.decomp.r1.bed | awk 'OFS="\t"{print $1,$2,$3,"rDNA_"NR,"0","na"}' | awk '$3-$2 >= 40000' > rDNA.decomp.r3.bed 
bedtools intersect -a rDNA.decomp.r1.bed -b rDNA.rb.pure.bed -wo | cut -f4 | sort | uniq -c | awk '{if($1 > 1){print $2}}' > multi.ids 
grep -wvf multi.ids rDNA.decomp.r1.bed | awk 'OFS="\t" {print $1,$2,$3,"rDNA",$5,$6}' > rDNA.decomp.true_r1.bed
grep -wf multi.ids rDNA.decomp.r1.bed > rDNA.decomp.multy.bed 
python3 cutbyBed.py -fasta ${assembly}.fa -bed rDNA.decomp.r3.bed > rDNA.decomp.r3.fasta 
[ -s rDNA.decomp.multy.bed ] && python3 cutbyBed.py -fasta CHM13v2.fasta -bed rDNA.decomp.multy.bed >> rDNA.decomp.r3.fasta
#Cut the rDNA unit into 5kb fragments (saved in rdna.cut.fa) and decompose the fragments by stringdecomposer.
stringdecomposer rDNA.decomp.r3.fasta rdna.cut.fa -v 50000 -t 1 -o ./strd
python3 convert2bed.py ./strd/final_decomposition.tsv
sed -e 's/:/\t/1' ./strd/final_decomposition.bed | awk 'OFS="\t" {gsub("-","\t",$2)}1' | awk 'OFS="\t" {print $1,$2+$4,$2+$5+1,$6,$7,$8}' | sort -k1,1V -k2,2n | uniq > ./strd/final_decomposition.true.bed
stv.sh ./strd/final_decomposition.true.bed 
awk 'OFS="\t" {print $1,$2,$3,"rDNA",$5,$6}' stv.bed | cat - rDNA.decomp.true_r2.dic.bed rDNA.decomp.true_r1.bed | sort -k1,1 -k2,2n > rDNA.decomp.bed 
python3 cutbyBed.py -fasta ${assembly}.fa -bed rDNA.decomp.bed > rDNA.decomp.fa
date