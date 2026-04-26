# Asian Pan-Genome project phase 1
<img src="Docs/APG_logo.png" alt="APG Project Logo" style="zoom:1%;" />

Welcome to the repository for APG phase 1 (APGp1).

In phase 1, we generated 320 *de novo* near-T2T assemblies from 160 East Asian (EAS) individuals. Detailed meta-information for each individual with all private identifiers removed, can be found in [`APGp1_metadata.csv`](APGp1_metadata.csv).

## Table of Contents

  * [Repository Structure](#repository-structure)
  * [Resources](#downloads)
    + [Genome Assembly](#genome-assemblies)
    + [Annotation](#annotation-files)
    + [Pangenome Graph](#pangenome-graphs)
    + [External Datasets](#external-datasets-used-in-this-study)
  * [Companion Papers & Repositories](#companion-papers--specialized-repositories)
  * [Contact](#contact)


## Repository structure
This GitHub repository primarily contains the analytical scripts and pipelines used in the APGp1 flagship study (Wu et al., unpublished).

including:
1. [Genome_assembly](https://github.com/Asian-Pan-Genome/APGp1/tree/main/assembly) - Genome assembly, gap-filling, polishing
2. [QC](https://github.com/Asian-Pan-Genome/APGp1/tree/main/qc) - Basic stats, QV, GCI, flagger, etc.
3. [Annotation](https://github.com/Asian-Pan-Genome/APGp1/tree/main/annotation) - Repeatome, centromere, rDNA, gene annotation 
4. [SV](https://github.com/Asian-Pan-Genome/APGp1/tree/main/SV-related) — SV decomposition (PanSVMerger), merging, comparison
5. [Pangenome_graph](https://github.com/Asian-Pan-Genome/APGp1/tree/main/Graph) — Graph construction, comparison, mapping
6. [Loss_of_function](https://github.com/Asian-Pan-Genome/APGp1/tree/main/Loss_of_function) — pLoF annotation and phasing
7. [Inversions](https://github.com/Asian-Pan-Genome/APGp1/tree/main/Inversions) — Large inversion detection
8. [Complex_loci](https://github.com/Asian-Pan-Genome/APGp1/tree/main/Complex_loci) — MHC and SMN structural haplotyping

Each folder contains its own `README.md` with detailed input/output specifications.

---

## Resources

### Sequencing reads and assemblies
| Data type | Accession |
|-----------|-----------|
| BioProject | [PRJCA030428](https://ngdc.cncb.ac.cn/bioproject/browse/PRJCA030428) |
| Genome Sequence Archive (Raw reads) | [HRA010014](https://ngdc.cncb.ac.cn/search/specific?db=hra&q=HRA010014)
| Assemblies (FASTA) | [PRJCA030428](https://ngdc.cncb.ac.cn/bioproject/browse/PRJCA030428) |

> **Note**: To protect participant confidentiality, assemblies and raw sequencing data are available for general scientific research through a controlled access process in accordance with relevant regulations. Applications can be submitted to the Data Access Committee of APG at NGDC (https://ngdc.cncb.ac.cn/).

---


### Annotation

Annotations are available for each APGp1 assembly.

| Type | Format | Description |
|-----------------|--------|-------------|
| [Repeat elements](https://genome.zju.edu.cn/APG/Resources#TE) | GFF | RepeatMasker annotation including SINE, LINE, LTR, etc. |
| [Centromeric satellite arrays](https://genome.zju.edu.cn/APG/Resources#CenSat) | BED | Pericentromeric and centromeric satellite annotation |
| [Centromeric HORs](https://genome.zju.edu.cn/APG/Resources#HOR) | BED | Centromeric high-order-repeat annotation |
| [rDNA arrays](https://genome.zju.edu.cn/APG/Resources#rDNA) | BED, FASTA | rDNA regions and individual rDNA copy sequences |
| [Protein-coding genes](https://genome.zju.edu.cn/APG/Resources#Gene) | GFF.gz | Liftoff + Exonerate + Augustus merged annotation |
| [HLA and C4 genes]() | GFF | Annotated using Immuannot |
| [SMN structural haplotypes (sHap)](https://github.com/Asian-Pan-Genome/APGp1/blob/main/Complex_loci/SMN/SMN_haplotypes_APGp1_HPRCy1_HGSVC3.csv) | TXT | sHap assignments for 434 fully resolved SMN loci |

---

### Pangenome Graphs

| Dataset | Method | Version | Reference | Haplotype size | Size (Gb) | Note |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| APGp1 | MC | 6.1.0 | T2T-CN1 | 320 | 3.418 | [access](https://genome.zju.edu.cn/APG/Resources#graphs)|
| APGp1 | MC | 6.1.0 | T2T-CHM13 | 320 | 3.429 |[access](https://genome.zju.edu.cn/APG/Resources#graphs) |
| APGp1 + HPRCy1 + HGSVC3 | MC | 6.1.0 | T2T-CN1 | 540 | 3.608 |[access](https://genome.zju.edu.cn/APG/Resources#graphs) |
| APGp1 + HPRCy1 + HGSVC3 | MC | 6.1.0 | T2T-CHM13 | 540 | 3.621 | [access](https://genome.zju.edu.cn/APG/Resources#graphs)|
| APGp1 | MG | 0.21-r606 | T2T-CN1 | 320 | 3.594 | [access](https://genome.zju.edu.cn/APG/Resources#graphs)|
| APGp1 | MG | 0.21-r606 | T2T-CHM13 | 320 | 3.548 |[access](https://genome.zju.edu.cn/APG/Resources#graphs) |
| APGp1 + HPRCy1 + HGSVC3 | MG | 0.21-r606 | T2T-CN1 | 540 | 3.904 | [access](https://genome.zju.edu.cn/APG/Resources#graphs)|
| APGp1 + HPRCy1 + HGSVC3 | MG | 0.21-r606 | GRCh38 | 540 | 3.397 |[access](https://genome.zju.edu.cn/APG/Resources#graphs) |
| HPRCy1 | MG | 0.21-r606 | T2T-CHM13 | 94 | 3.333 |[access](https://genome.zju.edu.cn/APG/Resources#graphs) |
| HGSVC3 | MG | 0.21-r606 | T2T-CHM13 | 130 | 3.402 |[access](https://genome.zju.edu.cn/APG/Resources#graphs) |
| HPRCy1eas-HGSVC3eas | MG | 0.21-r606 | T2T-CHM13 | 30 | 3.183 | [access](https://genome.zju.edu.cn/APG/Resources#graphs)|
| HPRCy1eas-HGSVC3eas | MC | 2.1.1 | T2T-CN1 | 30 | 3.202 | [access](https://genome.zju.edu.cn/APG/Resources#graphs)|
| CPC* | MC | 2.1.1 | T2T-CHM13 | 124 | 3.285 | [Gao et al., 2023](https://pog.fudan.edu.cn/cpc/download//CPC.Phase1.CHM13v2-full/CPC.Phase1.CHM13v2-full.gfa.gz) |
| HPRCy1* | MC | NA | T2T-CHM13 | 95 | 3.338 | [Liao et al., 2023](https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-chm13/hprc-v1.1-mc-chm13.gfa.gz) |
| CPC-HPRCy1* | MC | 2.1.1 | T2T-CHM13 | 212 | 3.510 | [Gao et al., 2023](https://pog.fudan.edu.cn/cpc/download//CPC.HPRC.Phase1.CHM13v2/CPC.HPRC.Phase1.CHM13v2.gfa.gz) |
| HPRCy1* | MG | 0.14 | T2T-CHM13 | 95 | 3.366 | [Liao et al., 2023](https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph/hprc-v1.0-minigraph-chm13.gfa.gz) |

---


### External Datasets

* Assembly

| Assembly | Version |
|----------|---------|
| [T2T-CN1](https://genome.zju.edu.cn/Downloads) | v1.0 |
| [T2T-CHM13](https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/analysis_set/chm13v2.0.fa.gz) | v2.0 |
| [GRCh38](https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_46/) | p14 |
| [HG002](https://github.com/marbl/HG002) | Q100 |
| [YAO](https://github.com/KANGYUlab/T2T-YAO-resources) | v1.1 |
| [HPRCy1](https://www.ncbi.nlm.nih.gov/datasets/) | year 1 |
| [HGSVC3](https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/) | phase 3 |


* Other Datasets

| Type | File | Note | Link |
|------------|--------|---------|------|
| Chain | CN1v1.0_hap_To_CHM13v2.0.over.chain.gz | T2T-CN1 v1.0 → T2T-CHM13 v2.0 | [Download]() |
| Chain | CN1v1.0_hap_To_GRCh38.p14.over.chain.gz | T2T-CN1 v1.0 → GRCh38.p14 | [Download]() |
| Chain | CHM13v2.0_To_CN1v1.0_hap.over.chain.gz | T2T-CHM13 v2.0 → T2T-CN1 v1.0 | [Download]() |
| Chain | GRCh38.p14_To_CN1v1.0_hap.over.chain.gz | GRCh38.p14 → T2T-CN1 v1.0 | [Download]() |
| Region | CN1v1_Easy_region.bed | Easy region in T2T-CN1 | [Download]() |
| Region | CN1v1_CMRG_region.bed | CMRG region in T2T-CN1 | [Download]() |
| Region | CN1v1_SD_region.bed | SD region in T2T-CN1 | [Download]() |
| Region | CN1v1_rDNA_region.bed | rDNA arrays in T2T-CN1 | [Download]() |
| Region | CN1v1_Centromere_region.bed | Centromere regions in T2T-CN1 | [Download]() |
| Region | CN1v1_CentromerePlus_region.bed | Centromere+5Mb regions in T2T-CN1 | [Download]() |
| Region | CN1v1_MHC_region.bed | MHC in T2T-CN1 | [Download]() |
| Region | CN1v1.0_haploid.RM.out.gff | TE annotation in T2T-CN1 by Repeatmasker | [Download]() |
| Region | CN1v1_VNTR_STR.anno | VNTR/STR in T2T-CN1 | [Download]() |
| GeneExpression | MAGE RNAseq | MAGE dataset for 1KGP | [Download](https://github.com/mccoy-lab/MAGE/) |


---



## Companion Papers & Repositories

For specific analyses and methodologies developed during APGp1, please refer to the following companion studies:

* [Centromere](https://github.com/Asian-Pan-Genome/Centromere)  (Sun et al., unpublished)
  

* [Archaic introgression](https://github.com/Asian-Pan-Genome/ArchaicIntrogression)  (Suo et al., unpulished)

    New method: [ASMaid](https://github.com/Asian-Pan-Genome/ASMaid)


* [Y chromosome](https://github.com/Asian-Pan-Genome/APGp1-Y)  (Liu et al., unpublished)


* [Complex regions]() (Han et al., unpublished)


* [Tibetan pangenome](https://doi.org/10.64898/2025.12.16.694547) (He et al., 2025, bioRxiv)


* [Schizophrenia pangenome study]() (Yang et al., ubpublished)


* [PG-NUMT](https://github.com/LiantingFu/NUMT_Analysis) ([Fu et al., 2026, BioRxiv](https://www.biorxiv.org/content/10.64898/2026.02.26.708114v1.full))


---

## Contact 
Please raise issues on this Github repository concerning this dataset.
For more informtion, please contact Dongya Wu (Zhejiang University) at wudongya@zju.edu.cn .



