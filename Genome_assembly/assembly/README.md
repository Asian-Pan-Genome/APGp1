# Human T2T Phased Genome Assembly Pipeline in APGp1

This repository contains a bioinformatic pipeline for generating Telomere-to-Telomere phased human genomes, by integrating PacBio HiFi, Ultra-long (>100 Kbp) ONT reads, and parental k-mer (Trio) or HiC data.

For each individual, we generated multiple versions of genome assemblies. Comprehensive meta-information is available [here](https://github.com/Asian-Pan-Genome/APGp1/blob/main/Genome_assembly/APGp1_assembly_meta-information.csv).

Generally, for individuals with trio data, we primarily employed hifiasm (trio mode) using high-depth PacBio HiFi and ultra-long (>100 kbp) ONT reads. A further hierarchical gap-filling integrating assemblies from hifiasm (HiC mode) and verkko (trio mode) was performed. For individuals lacking parental genomic data, we utilized hifiasm assemblies (HiC mode) and assigned paternal/maternal haplotypes based on the presence of sex chromosomes along with rigorous manual curation.

Note some exceptions:

* For ```C041-CHA-N01-01```, due to unforeseen technical failures in generating hifiasm assemblies (both trio and HiC modes), the final assembly for this individual is based on the Verkko (trio mode) version.

* For ```C070-CHA-NE10-01```, due to a persistent failure in the Verkko (trio mode) assembly process for unknown technical reasons, verkko-derived sequences were not incorporated into the gap-filling stage for this individual.

* For ```C085-CHA-C05-01``` and ```C086-CHA-C06-01```, initial phasing attempts failed, likely due to labelling inconsistencies between ONT and HiFi libraries. Following data recalibration and adjustment, hifiasm (trio mode) assemblies were successfully generated and utilized.

* For ```C144-CHU03-01```, phasing quality was assessed by cross-referencing HiC-phased contigs with parental k-mers. We observed a significant proportion of indistinguishable contigs, indicating sub-optimal biological phasing. Consequently, the HiC-phased assemblies for this individual were excluded from the gap-filling pipeline..




## Data QC and K-mer profiling
```01_ngs_fastp_yak_meryl.sh```: NGS trimming and k-mer library building using yak and meryl for trio-phasing and QV/phasing accuracy estimation.

```03_hifi_filt_stat.sh```: HiFi reads filtering. 

```04_ont_filt_stat.sh```: ONT reads filtering. 

## Trio/HiC-phased Assembly
```R3_verkko_trio_ont100k.sh```: [Verkko](https://github.com/marbl/verkko) in trio mode (for individuals with trio data). 

```R4_hifiasm_trio_ont100k.sh```: [Hifiasm](https://github.com/chhylp123/hifiasm) in trio mode (for individuals with trio data). 

```R5_hifiasm_hic_ont.sh```: [Hifiasm](https://github.com/chhylp123/hifiasm) in HiC mode. 
* The HiC phased contigs by hifiasm were subsequently evaluated by parental k-mers using ```yak trioeval```, and we re-phased these contigs into biologically paternal and maternal haplotype assemblies based on yak results. See the perl script [R5a_correct_trioReassign.pl](https://github.com/Asian-Pan-Genome/APGp1/blob/main/Genome_assembly/assembly/R5a_correct_trioReassign.pl).

## Multi-assembly gap filling
```R7_gap_filling_by_assembly_and_ONT_mapping.sh```: 

* Backbone: use hifiasm trio-phased assemblies as the primary assembly.
  
* Gap-filling: use Hifiasm HiC-phased and verkko trio-phased assemblies to fill gaps.
  
* ```gfasm.pl``` is a custom script to utilize assemblies from different strategies or tools to fill gaps. Specifically, to fill the gaps in reference backbone, query contigs were mapped against the reference contigs using minimap2 (v2.26-r1175; Li, 2018), retaining alignments with >20 Kbp aligned length and mapping quality > 55. To avoid overfilling artifacts, we required that the flanking unaligned proportion be less than 0.05 of the total length of reference contig, and the aligned proportion of the reference contig aligned within the query contig exceed 0.80.


## Contact

* For more information, please raise an issue or contact Dongya Wu (Eric) at wudongya@zju.edu.cn.
