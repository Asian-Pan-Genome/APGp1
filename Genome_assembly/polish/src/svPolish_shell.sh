#!/bin/bash
if [[ $# != 5 ]]; then
	echo "Usage: sh $0 sample_ID hap[MAT|PAT] hifi2asm.bam ont2asm.bam draft"
	exit 1
fi

id=$1
hap=$2
hifi2asm=$(realpath $3)
ont2asm=$(realpath $4)
draft=$(realpath $5)
wk=`pwd`

# CONFIGURE OF DATA, SOFTWARE..
if [ -s $src/init.conf   ]; then
	echo "Load configure from $src/init.conf"
	source $src/init.conf
else
	echo "Can not assess to init.conf in $src"
	exit -1
fi

echo "#!/bin/bash
#SBATCH --job-name=sniffles
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --partition=cpu
#SBATCH --mem=30g

sniffles --long-ins-length 5000 --input   ${hifi2asm} --reference  ${draft} --threads 16 --vcf allhifi.sniffles.vcf
sniffles --long-ins-length 20000 --input  ${ont2asm}  --reference  ${draft} --threads 16 --vcf ${hap}_ont.sniffles.vcf
# filter DNB, small contigs, and keep 1/1
python3 $src/keep_INDELs_DUP_homo.py allhifi.sniffles.vcf > allhifi.sniffles.filt.vcf
python3 $src/keep_INDELs_DUP_homo.py ${hap}_ont.sniffles.vcf > ${hap}_ont.sniffles.filt.vcf

source /slurm/home/zju/zhanglab/yangchentao/miniconda3/bin/activate polish
echo "$wk/allhifi.sniffles.filt.vcf" > filelist.txt
echo "$wk/${hap}_ont.sniffles.filt.vcf" >> filelist.txt
echo "${hifi2asm}" >bamlist.txt
echo "${ont2asm}" >>bamlist.txt

jasmine --run_iris --dup_to_ins genome_file=${draft} bam_list=bamlist.txt file_list=filelist.txt out_file=Iris_jasmine.hifi_ont.sniffles.vcf 

# correct sv
grep '^#' Iris_jasmine.hifi_ont.sniffles.vcf >header
grep -v '^#' Iris_jasmine.hifi_ont.sniffles.vcf|sort -k1,1V -k2n > vcf
cat header vcf |bgzip > Iris_jasmine.hifi_ont.sniffles.sort.vcf.gz && rm header vcf
tabix Iris_jasmine.hifi_ont.sniffles.sort.vcf.gz
bcftools consensus -c polish.chain -H 1 -f ${draft} Iris_jasmine.hifi_ont.sniffles.sort.vcf.gz > Iris_jasmine.hifi_ont.sniffles.polished.fasta
date " > svPolish.sh

