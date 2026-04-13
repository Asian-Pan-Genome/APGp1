# Human T2T Phased Genome Assembly Pipeline in APGp1

This repository contains a bioinformatic pipeline for generating Telomere-to-Telomere phased human genomes, by integrating PacBio HiFi, Ultra-Long ONT, and Parental k-mer (Trio) or Hi-C data.

## Data QC and K-mer profiling
```01_ngs_fastp_yak_meryl.sh```: NGS trimming and k-mer library building using yak and meryl for trio-phasing and QV/phasing accuracy estimation.

```03_hifi_filt_stat.sh```: HiFi reads filtering. 

```04_ont_filt_stat.sh```: ONT reads filtering. 

## Trio/HiC-phased Assembly
```R3_verkko_trio_ont100k.sh```: [Verkko](https://github.com/marbl/verkko) in trio mode (for individuals with trio data). 

```R4_hifiasm_trio_ont100k.sh```: [Hifiasm](https://github.com/chhylp123/hifiasm) in trio mode (for individuals with trio data). 

```R5_hifiasm_hic_ont.sh```: [Hifiasm](https://github.com/chhylp123/hifiasm) in Hi-C mode. 


## Multi-assembly gap filling
```R7_gap_filling_by_assembly_and_ONT_mapping.sh```: 

* Backbone: use hifiasm trio-phased assemblies as the primary assembly.
  
* Gap-filling: use Hifiasm HiC-phased and verkko trio-phased assemblies to fill gaps.
  
* ```gfasm.pl``` is a custom script to utilize assemblies from different strategies or tools to fill gaps. Specifically, to fill the gaps in reference backbone, query contigs were mapped against the reference contigs using minimap2 (v2.26-r1175; Li, 2018), retaining alignments with >20 Kbp aligned length and mapping quality > 55. To avoid overfilling artifacts, we required that the flanking unaligned proportion be less than 0.05 of the total length of reference contig, and the aligned proportion of the reference contig aligned within the query contig exceed 0.80.


## Contact

* For more information, please raise an issue or contact Dongya Wu (Eric) at wudongya@zju.edu.cn.
