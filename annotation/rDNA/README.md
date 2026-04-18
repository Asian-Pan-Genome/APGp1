# Human rDNA Annotation Pipeline for APGp1

This repository contains pipeline for annonating rDNA array in human genome and classifying haplotypes 

## Requirements
- rDNA reference (KY962518.1 in this pipeline)
- ncbi blast (v2.15.0+)
- minimap2
- bedtools
- stringdecomposer
- plink

## rDNA Annotation and decomposition
First, the rDNA reference sequence is transform to a blast database via 
```bash
makeblastdb -in ${human_rdna_reference}.fa -parse_seqids -title "rdna" -dbtype nucl -out ${rdna_db}/rdna
```
I also create a database for 45S coding region (i.e. the coordinate 0-13332) for further decomposition use in ```${rdna_db}/rb```
and for each assembly, the rDNA regions are annotated from the following pipeline:
```bash 
blastn -db ${rdna_db}/rdna -query ${assembly}.fa -out rDNA.tbl -outfmt 6 -num_threads 8 -gapopen 3 -gapextend 1
awk '$3 > 85 && $11 == 0' rDNA.tbl | awk '$8-$7 > 1000' | sort -k1,1V -k7,7n | awk 'OFS="\t" {print $1,$7,$8,"rdna"}' | bedtools merge -i - -d 2000 | awk 'OFS="\t" {if($3-$2 > 40000) print $1,$2-1,$3}' > ${assembly}.rdna.bed
python3 cutbyBed.py -fasta ${assembly}.fa -bed ${assembly}.rdna.bed > ${assembly}.rdna.fa
```
Then, ```rDNA.decompose.sh``` is used to decompose the rDNA array in ```${assembly}.rdna.fa``` to rDNA unit.
Several scripts are contained in the pipeline ```rDNA.decompose.sh```:
* ```to_decomp.py```: generate confidence rDNA unit from the 45S coding region coordinate.
* ```cutbyBed.py```: get the fasta sequence from bed.
* ```convert2bed.py```: a script in [HORmon](https://github.com/ablab/HORmon/tree/main/HORmon) to covert the stringdecomposer tsv result to bed format.
* ```stv.sh```: the script to get the rDNA 5kb segments component order from the stringdecomposer result. The script is first write via *** and I make several change to adopt to this situation.

## rDNA variant calling and haplotype classification
For each rDNA copy, the varians are generated via [Mummer](https://github.com/mummer4/mummer) as:
```bash
nucmer --maxmatch -t 5 -l 100 -c 1000 -D 1 ${human_rdna_reference}.fa rDNA${index}.fasta --delta ./map/${index}.delta
delta-filter -m -i 90 -l 100 ./map/${index}.delta > ./map/${index}.filter.delta 
show-coords -THrd ./map/${index}.filter.delta > ./map/${index}.filter.coords
syri -c ./map/${index}.filter.coords -d ./map/${index}.filter.delta -r ${human_rdna_reference}.fa -q rDNA${index}.fasta --dir ./sv/
mv ./sv/syri.vcf ./sv/${index}.vcf
```
And all SNPs in the VCFs are extracted and coverted to a bed format as:
```bash
for a in `ls sv/*.vcf`; do filename=`basename $a`; name=${filename%.vcf}; grep -E "SNP" $a | awk 'OFS="\t" {if($1 !~ "#"){print $1,$2-1,$2,$3,"1",$4":"$5,$8}}'; done > SNPs.bed
```
The SNPs are then used to get the PCA result as:
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
And finally, the pca is viewed via the script ```PCA.R`` and haplotypes are classificated via the pca plot