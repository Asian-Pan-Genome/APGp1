#!/usr/bin/sh

sample=C001-CHA-E01-01
thread=32

ResultPath="xxx/Result/"$sample
mkdir -p $ResultPath
cd $ResultPath

date
#===============VG Giraffe Mapping======================
Graphpath="xxx/APG1/Graph/"
pref=$Graphpath"APGp1-MC-CN1v1.d2" # Graph name

NGSpath="xxx/APG1/NGS/"$sample"/"
h1=$NGSpath"*R1.fq.gz"
h2=$NGSpath"*R2.fq.gz"
echo $h1
echo $h2

vg giraffe \
	--sample $sample \
	--read-group "ID:1 LB:lib1 SM:"$sample" PL:illumina PU:unit1" \
	-Z $pref.gbz -m $pref.min -d $pref.dist \
	-p -f $h1 -f $h2 -t $thread -o BAM > $sample.bam

date
echo 'finish vg giraffe'

samtools view -h $sample.bam | sed -e "s/CN1v1#0#//g" | samtools sort --thread $thread -O BAM > $sample.sort.bam
samtools index -@ $thread $sample.sort.bam

rm $sample.ba*

#=============DeepVariant Call Variant==================
#With min_mapping_quality=1,keep_legacy_allele_counter_behavior=true,normalize_reads=true

DATA="xxx/APG1/"
REF="xxx/APG1/Ref/CN1v1.0_t2tm.fasta"
DeepVariantPath="xxx/deepvariant.simg"
  singularity run -B $DATA:$DATA $DeepVariantPath \
  /opt/deepvariant/bin/run_deepvariant \
  --model_type WGS  \
  --ref $REF \
  --reads $ResultPath/$sample.sort.bam \
  --intermediate_results_dir $ResultPath/tmp \
  --output_vcf $ResultPath/$sample.vcf.gz \
  --output_gvcf $ResultPath/$sample.g.vcf.gz \
  --make_examples_extra_args="min_mapping_quality=1,keep_legacy_allele_counter_behavior=true,normalize_reads=true" \
  --num_shards 32

date
echo 'finish!'
