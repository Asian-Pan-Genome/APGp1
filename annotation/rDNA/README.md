# Human rDNA Analysis for APGp1

This repository contains a pipeline for annotating rDNA arrays in the human genome and classifying haplotypes.

## Requirements
- rDNA reference (KY962518.1 in this pipeline)
- ncbi blast (v2.15.0+)
- minimap2
- bedtools
- stringdecomposer
- plink

## rDNA annotation and decomposition
First, the rDNA reference sequence is converted into a BLAST database:
```bash
makeblastdb -in ${human_rdna_reference}.fa -parse_seqids -title "rdna" -dbtype nucl -out ${rdna_db}/rdna
```
A database for the 45S coding region (coordinates 0–13332) is also created for downstream decomposition and stored as ```${rdna_db}/rb```.
For each assembly, rDNA regions are annotated using the following pipeline:
```bash 
blastn -db ${rdna_db}/rdna -query ${assembly}.fa -out rDNA.tbl -outfmt 6 -num_threads 8 -gapopen 3 -gapextend 1
awk '$3 > 85 && $11 == 0' rDNA.tbl | awk '$8-$7 > 1000' | sort -k1,1V -k7,7n | awk 'OFS="\t" {print $1,$7,$8,"rdna"}' | bedtools merge -i - -d 2000 | awk 'OFS="\t" {if($3-$2 > 40000) print $1,$2-1,$3}' > ${assembly}.rdna.bed
python3 cutbyBed.py -fasta ${assembly}.fa -bed ${assembly}.rdna.bed > ${assembly}.rdna.fa
```
Then, ```rDNA.decompose.sh``` is used to decompose the rDNA array in ```${assembly}.rdna.fa``` into rDNA units.
The pipeline includes several scripts::
* ```to_decomp.py```: generates confident rDNA units from the 45S coding region coordinates.
* ```cutbyBed.py```: extracts FASTA sequences from a BED file.
* ```convert2bed.py```: a script from [HORmon](https://github.com/ablab/HORmon/tree/main/HORmon) that converts stringdecomposer TSV output to BED format.
* ```stv.sh```: derives the component order of 5 kb rDNA segments from the stringdecomposer results. This script was originally deposited at (https://github.com/fedorrik/stv_chm13) and has been modified to fit this pipeline.

## rDNA variant calling and haplotype classification
For each rDNA copy, the varians are called using [Mummer](https://github.com/mummer4/mummer) as follows:
```bash
nucmer --maxmatch -t 5 -l 100 -c 1000 -D 1 ${human_rdna_reference}.fa rDNA${index}.fasta --delta ./map/${index}.delta
delta-filter -m -i 90 -l 100 ./map/${index}.delta > ./map/${index}.filter.delta 
show-coords -THrd ./map/${index}.filter.delta > ./map/${index}.filter.coords
syri -c ./map/${index}.filter.coords -d ./map/${index}.filter.delta -r ${human_rdna_reference}.fa -q rDNA${index}.fasta --dir ./sv/
mv ./sv/syri.vcf ./sv/${index}.vcf
```
All SNPs in the VCFs are extracted and coverted to a BED format as:
```bash
for a in `ls sv/*.vcf`; do filename=`basename $a`; name=${filename%.vcf}; grep -E "SNP" $a | awk 'OFS="\t" {if($1 !~ "#"){print $1,$2-1,$2,$3,"1",$4":"$5,$8}}'; done > SNPs.bed
```
The SNPs are then used to perform PCA:
```bash
sort -k6,6 -k2,2n all.snp_full.bed > all.snp.sorted.bed
#Merge the snps according to the coordinate
python3 merge_sv.py -bed all.snp.sorted.bed > merge.snp.bed
#filter the varinat with AC > ${threhold}. This pipeline set the threhold to 330, i.e. the AF > 0.01
awk -v t=${threhold} '$5 > t' ./merge.snp.bed > merge.snp.alover0.01.bed
sort -k2,2n merge.snp.alover0.01.bed | awk 'OFS="\t" {print $1,$2,$3,$4"_"$2,$5,$6,$7}' > snp.ids.bed
python3 cutbyBed.py -fasta ${human_rdna_reference}.fa -bed snp.ids.bed -infoonly | cut -f1 -d " "| sed 's/>//g' | awk '{if(NR%2 == 1){id=$1}else{print id"\t"$1}}' | sort -k1,1V | uniq > snp.info
#Transform the bed to plink format
python3 toplink.py -bed snp.ids.bed -info snp.info > snp.ped
awk 'OFS="\t" {print $1,$4,"0",$3}' snp.ids.bed | uniq  > snp.map
plink --file snp --make-bed --allow-extra-chr
plink --file snp --allow-extra-chr --pca --out pca
```
Finally, the PCA results are visualized using the ```PCA.R`` script, and haplotypes are classified based on the PCA plot.
