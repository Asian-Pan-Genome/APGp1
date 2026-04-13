# Asian Pan-Genome project phase 1
<img src="Docs/APG_logo.png" alt="APG Project Logo" style="zoom:1%;" />

Welcome to the repository for APG Phase 1 (APGp1). In this phase, we have generated a total of 320 de novo near-T2T assemblies from 160 East Asian (EAS) individuals. Detailed sequencing information for each individual is available in [`APGp1_metadata.csv`](APGp1_metadata.csv).

## Table of Contents

  * [Repository Structure](#repository-structure)
  * [Downloads](#downloads)
    + [Genome Assemblies](#genome-assemblies)
    + [Reference Assemblies Used in This Study](#reference-assemblies-used-in-this-study)
    + [Annotation Files](#annotation-files)
    + [Pangenome Graphs](#pangenome-graphs)
    + [Variant Datasets](#variant-datasets)
    + [Large Inversions](#large-inversions)
    + [LiftOver Resources](#liftover-resources)
    + [External Datasets Used in This Study](#external-datasets-used-in-this-study)
  * [Pipeline & Scripts](#pipeline--scripts)
    + [Direct Links to External Repositories](#direct-links-to-external-repositories)
  * [Companion Papers & Specialized Repositories](#companion-papers--specialized-repositories)
  * [Contact](#contact)


## Repository Structure
This GitHub repository primarily contains the analytical scripts and pipelines used in the APGp1 flagship paper (Wu et al., unpublished).

including:
1. [Genome_assembly](https://github.com/Asian-Pan-Genome/APGp1/tree/main/assembly) - Genome assembly, gap-filling, polishing
2. [Annotation](https://github.com/Asian-Pan-Genome/APGp1/tree/main/annotation) - Repeat, centromere, rDNA, gene annotation 
3. [SV](https://github.com/Asian-Pan-Genome/APGp1/tree/main/SV-related) — SV decomposition (PanSVMerger), merging, comparison, Fst
4. [Pangenome_graph](https://github.com/Asian-Pan-Genome/APGp1/tree/main/Graph) — MC graph construction, mapping, variant calling
5. [Loss_of_function](https://github.com/Asian-Pan-Genome/APGp1/tree/main/Loss_of_function) — pLoF annotation and phasing
6. [Inversions](https://github.com/Asian-Pan-Genome/APGp1/tree/main/Inversions) — Large inversion detection and validation
7. [Complex_loci](https://github.com/Asian-Pan-Genome/APGp1/tree/main/Complex_loci) — MHC and SMN structural haplotyping

Each folder contains its own `README.md` with detailed input/output specifications.

---

## Downloads

### Genome Assemblies

The 320 phased haplotype-resolved genome assemblies (160 individuals × 2 haplotypes) are available through controlled access at the National Genomics Data Center (NGDC).

| Data type | Accession |
|-----------|-----------|
| BioProject | [PRJCA030428](https://ngdc.cncb.ac.cn/bioproject/browse/PRJCA030428) |
| Genome Sequence Archive (raw reads) | [HRA010014](https://ngdc.cncb.ac.cn/search/specific?db=hra&q=HRA010014)
| Assemblies (FASTA) | Apply via NGDC Data Access Committee |

> **Note**: To protect participant confidentiality, assemblies and raw sequencing data are available for general scientific research through a controlled access process. Applications can be submitted to the Data Access Committee of APG at NGDC.

---

### Reference Assemblies Used in This Study

| Assembly | Version |
|----------|---------|
| [T2T-CN1](https://genome.zju.edu.cn/Downloads) | v1.0 |
| [T2T-CHM13](https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/analysis_set/chm13v2.0.fa.gz) | v2.0 |
| [GRCh38](https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_46/) | p14 |
| [HG002](https://github.com/marbl/HG002) (Q100) | - |
| [HPRCy1 assemblies](https://www.ncbi.nlm.nih.gov/datasets/) | - |
| [HGSVC3 assemblies](https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC3/working/) | - |

---

### Annotation Files

All annotations are available for each APGp1 assembly. For bulk download, please contact the corresponding authors.

| Annotation type | Format | Description |
|-----------------|--------|-------------|
| Repeat elements (RepeatMasker) | BED, OUT | Full repeat annotation including SINE, LINE, LTR, etc. |
| Centromeric satellites (αSat, HSat1-3, βSat, γSat) | BED | Pericentromeric and centromeric satellite annotation |
| rDNA arrays and copies | BED, FASTA | rDNA regions and individual rDNA copy sequences with haplotypes (Hap0–Hap3) |
| Protein-coding genes (hybrid annotation) | GFF, GTF | Liftoff + Exonerate + Augustus merged annotation |
| HLA and C4 genes | GFF | Annotated using Immuannot |
| SMN locus structural haplotypes | TXT | sHap assignments for 434 fully resolved SMN loci |

---

### Pangenome Graphs

| Dataset | Method | Version | Reference | Haplotype size | Nodes (M) | Edges (M) | Size (Gb) | Note |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| APGp1 | MC | 6.1.0 | T2T-CN1 | 320 | 87.868 | 120.872 | 3.418 | |
| APGp1 | MC | 6.1.0 | T2T-CHM13 | 320 | 86.969 | 120.239 | 3.429 | |
| APGp1 + HPRCy1 + HGSVC3 | MC | 6.1.0 | T2T-CN1 | 540 | 156.623 | 215.971 | 3.608 | |
| APGp1 + HPRCy1 + HGSVC3 | MC | 6.1.0 | T2T-CHM13 | 540 | 156.385 | 217.306 | 3.621 | |
| APGp1 | MG | 0.21-r606 | T2T-CN1 | 320 | 0.878 | 1.290 | 3.594 | |
| APGp1 | MG | 0.21-r606 | T2T-CHM13 | 320 | 0.788 | 1.153 | 3.548 | |
| APGp1 + HPRCy1 + HGSVC3 | MG | 0.21-r606 | T2T-CN1 | 540 | 1.357 | 1.997 | 3.904 | |
| APGp1 + HPRCy1 + HGSVC3 | MG | 0.21-r606 | GRCh38 | 540 | 0.714 | 1.042 | 3.397 | |
| HPRCy1 | MG | 0.21-r606 | T2T-CHM13 | 94 | 0.612 | 0.883 | 3.333 | |
| HGSVC3 | MG | 0.21-r606 | T2T-CHM13 | 130 | 0.714 | 1.033 | 3.402 | |
| HPRCy1eas-HGSVC3eas | MG | 0.21-r606 | T2T-CHM13 | 30 | 0.249 | 0.359 | 3.183 | |
| HPRCy1eas-HGSVC3eas | MC | 2.1.1 | T2T-CN1 | 30 | 41.676 | 57.394 | 3.202 | |
| CPC* | MC | 2.1.1 | T2T-CHM13 | 124 | 64.057 | 89.190 | 3.285 | Gao et al., 2023 |
| HPRCy1* | MC | NA | T2T-CHM13 | 95 | 92.880 | 128.166 | 3.338 | Liao et al., 2023 |
| CPC-HPRCy1* | MC | 2.1.1 | T2T-CHM13 | 212 | 119.125 | 164.899 | 3.510 | Gao et al., 2023 |
| HPRCy1* | MG | 0.14 | T2T-CHM13 | 95 | 0.494 | 0.739 | 3.366 | Liao et al., 2023 |

---

### Variant Datasets

| Dataset | Variant types | Format | Description |
|---------|---------------|--------|-------------|
| Graph-decomposed variants (APGp1) | SNP, InDel, SV, MNP | VCF | 149,808 SVs across 71,434 sites (T2T-CN1 reference) |
| Graph-decomposed variants (GLOBALp1) | SNP, InDel, SV, MNP | VCF | 116,097 SV loci containing >483,000 SVs |
| APGp1-private SVs | SV (≥50 bp) | VCF | 18,284 SV sites unique to APGp1 (72.5% singleton) |
| Population-stratified SVs | SV (≥50 bp) | VCF, TXT | 2,935 SVs with Hudson *Fst* > 0.288 (top 5%) between EAS and non-EAS |
| pLoF variants | Frameshift, stop-gain, splice | VCF | High-confidence pLoF variants per individual (median 195 per haplotype) |
| CNV calls | Gene CNV | TXT | Copy number variations for 2,442 genes across 320 assemblies |

---


### LiftOver Resources

| Chain file | Source → Target | Link |
|------------|-----------------|------|
| T2T-CN1 ↔ T2T-CHM13 | T2T-CN1 v1.0 ↔ T2T-CHM13 v2.0 | [Download]() |
| GRCh38 ↔ T2T-CN1 | GRCh38 p14 ↔ T2T-CN1 v1.0 | [Download]() |

---

### External Datasets Used in This Study

| Dataset | Description | Link |
|---------|-------------|------|
| [HGDP](https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGDP/data/) | Whole-genome sequences of 929 diverse individuals |
| [GIAB HG006/HG007](https://www.nist.gov/programs-projects/genome-bottle) | NGS reads for EAS individuals |
| [T2T-CHM13 Hi-C](https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/arima/) | Hi-C data for T2T-CHM13 |
| [gnomAD v4.1](https://storage.googleapis.com/gcp-public-data--gnomad/release/4.1/vcf/joint) | Population frequency data |
| [GTEx v8](https://gtexportal.org/) | Tissue-specific expression |

---



## Companion Papers & Specialized Repositories

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



