# Asian Pan-Genome project phase 1
Welcome to the repository for APG Phase 1 (APGp1). In this phase, we have generated a total of 320 de novo near-T2T assemblies from 160 East Asian (EAS) individuals.

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
1. [Genome assembly](https://github.com/Asian-Pan-Genome/APGp1/tree/main/assembly) - Genome assembly, gap-filling, polishing
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

> **Note**: To protect participant confidentiality, assemblies and raw sequencing data are available for general research through a controlled access process. Applications can be submitted to the Data Access Committee of APG at NGDC.

**Summary statistics**:
- 320 haploid assemblies (maternal + paternal from 160 EAS individuals)
- Average contig N50: 144.3 Mbp
- Average QV: 64.5 (<1 error per Mbp)
- Total assembly size range: 5.926 – 6.000 Gbp per individual

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

| Graph | Reference backbone | Haplotypes | Nodes | Edges | Size | Link |
|-------|-------------------|------------|-------|-------|------|------|
| APGp1 MC graph | T2T-CN1 v1.0 | 320 | 87.9M | 120.9M | 3.42 Gbp | Available upon request |
| APGp1 MC graph | T2T-CHM13 v2.0 | 320 | - | - | 3.45 Gbp | Available upon request |
| GLOBALp1 MC graph | T2T-CN1 v1.0 | 540 | 156.6M | 216.0M | 3.61 Gbp | Available upon request |
| HPRCy1 MC graph | T2T-CHM13 v2.0 | 47 | - | - | https://github.com/human-pangenomics/hpp_pangenome_resources |
| CPC MC graph | T2T-CHM13 v2.0 | 124 | 64.1M | 89.2M | 3.28 Gbp | https://pog.fudan.edu.cn/cpc/#/data |

> Graph files are in GFA format. For access, please contact the corresponding authors.

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

### Large Inversions

| Inversion | Location | Size | Population frequency | Validation |
|-----------|----------|------|---------------------|------------|
| 5p13.2-5q13.3 | chr5 (pericentric) | ~39 Mbp | Singleton (C123-01#Mat) | Hi-C, long-read, PCR |
| 8p23.1 | chr8 | ~4.6 Mbp | EAS-enriched | Long-read, Bionano |
| 3q29 | chr3 | ~346 Kbp | EAS & EUR enriched | Hi-C |
| 16q23.1 | chr16 | ~19 Kbp | Fixed in EAS | Long-read |

Full list of 159 inversions available in **Supplementary Table 13**.

---

### LiftOver Resources

| Chain file | Source → Target | Link |
|------------|-----------------|------|
| T2T-CN1 ↔ T2T-CHM13 | T2T-CN1 v1.0 ↔ T2T-CHM13 v2.0 | Available upon request |
| GRCh38 ↔ T2T-CN1 | GRCh38 p14 ↔ T2T-CN1 v1.0 | Available upon request |

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

---

## Pipeline & Scripts

This section lists all custom scripts and workflows developed for the APGp1 study. For each script, we provide the purpose, input/output specifications, and responsible contact. All scripts are available in the [APGp1 GitHub repository](https://github.com/Asian-Pan-Genome/APGp1).

> **Note**: No new software was developed for this study. All scripts are wrappers or pipelines that chain existing tools. For inquiries about specific scripts, please contact the responsible author directly.

---


| Category | Script | Path | Contact |
|----------|--------|------|---------|
| **Assembly** | | | |
| | Gap-filling by assemblies | [`01_assembly/gfasm.pl`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/01_assembly/gfasm.pl) | Dongya Wu |
| | Gap-filling by ONT reads | [`01_assembly/gapfill_by_ont.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/01_assembly/gapfill_by_ont.sh) | Dongya Wu, Chentao Yang |
| | Polishing with NextPolish2 | [`01_assembly/polish_nextpolish2.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/01_assembly/polish_nextpolish2.sh) | Chentao Yang |
| | Manual curation | [`01_assembly/manual_curation/`](https://github.com/Asian-Pan-Genome/APGp1/tree/main/01_assembly/manual_curation) | Dongya Wu |
| **Annotation** | | | |
| | RepeatMasker + cenSat annotation | [`02_annotation/02a_repeatome/annotate_satellites.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/02_annotation/02a_repeatome/annotate_satellites.sh) | Yanqing Sun |
| | Custom satellite filter | [`02_annotation/02a_repeatome/custom_satellite_filter.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/02_annotation/02a_repeatome/custom_satellite_filter.sh) | Yanqing Sun |
| | Centromere boundary annotation | [`02_annotation/02b_centromere/centromere_boundary_annotator.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/02_annotation/02b_centromere/centromere_boundary_annotator.py) | Yanqing Sun |
| | Centromere analysis workflow | [`02_annotation/02b_centromere/run_centromere_analysis.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/02_annotation/02b_centromere/run_centromere_analysis.sh) | Yanqing Sun |
| | rDNA haplotyping | [`02_annotation/02c_rdna/rdna_haplotyping.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/02_annotation/02c_rdna/rdna_haplotyping.py) | Lei Nie |
| | rDNA array homogenization | [`02_annotation/02c_rdna/rdna_array_homogenization.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/02_annotation/02c_rdna/rdna_array_homogenization.py) | Lei Nie |
| | Hybrid gene annotation | [`02_annotation/02d_gene/hybrid_annotation_pipeline.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/02_annotation/02d_gene/hybrid_annotation_pipeline.sh) | Quanyu Chen |
| **Pangenome Graph** | | | |
| | MC graph construction | [`03_pangenome_graph/03a_construction/build_minigraph_cactus.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/03_pangenome_graph/03a_construction/build_minigraph_cactus.sh) | Dongya Wu |
| | Graph filtering (vg clip) | [`03_pangenome_graph/03a_construction/graph_filtering.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/03_pangenome_graph/03a_construction/graph_filtering.sh) | Dongya Wu |
| | NGS mapping with vg giraffe | [`03_pangenome_graph/03b_mapping/vg_giraffe_mapping.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/03_pangenome_graph/03b_mapping/vg_giraffe_mapping.sh) | Qingyang Ni |
| | HiFi mapping with GraphAligner | [`03_pangenome_graph/03b_mapping/graphaligner_mapping.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/03_pangenome_graph/03b_mapping/graphaligner_mapping.sh) | Qingyang Ni |
| | Graph-based variant calling | [`03_pangenome_graph/03c_variant_calling/deepvariant_on_graph.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/03_pangenome_graph/03c_variant_calling/deepvariant_on_graph.sh) | Qingyang Ni |
| | Reference backbone comparison | [`03_pangenome_graph/03d_graph_comparison/compare_reference_backbones.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/03_pangenome_graph/03d_graph_comparison/compare_reference_backbones.py) | Dongya Wu |
| **SV Related** | | | |
| | PanSVMerger (SV pruning) | [`04_sv_related/04a_decomposition/PanSVMerger/pansvmerger.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/04_sv_related/04a_decomposition/PanSVMerger/pansvmerger.py) | Chentao Yang |
| | SV merging (SURVIVOR+bcftools) | [`04_sv_related/04b_merging/merge_sv_sets.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/04_sv_related/04b_merging/merge_sv_sets.sh) | Chentao Yang, Quanyu Chen |
| | SV caller comparison | [`04_sv_related/04c_comparison/compare_sv_callers.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/04_sv_related/04c_comparison/compare_sv_callers.py) | Chentao Yang |
| | Hudson *Fst* calculation | [`04_sv_related/04d_population_stratification/compute_hudson_fst.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/04_sv_related/04d_population_stratification/compute_hudson_fst.py) | Chentao Yang |
| | Allele frequency calculation | [`04_sv_related/04d_population_stratification/sv_allele_frequency.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/04_sv_related/04d_population_stratification/sv_allele_frequency.py) | Chentao Yang |
| **Loss-of-Function** | | | |
| | pLoF annotation with VEP | [`05_loss_of_function/plof_annotation_vep.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/05_loss_of_function/plof_annotation_vep.sh) | Anguo Liu |
| | pLoF phasing analysis | [`05_loss_of_function/plof_phasing_analysis.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/05_loss_of_function/plof_phasing_analysis.py) | Anguo Liu |
| | Compound pLoF enrichment | [`05_loss_of_function/compound_plof_enrichment.R`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/05_loss_of_function/compound_plof_enrichment.R) | Anguo Liu |
| **Inversions** | | | |
| | Inversion calling (PAV+SVIM-asm+LSGvar) | [`06_inversions/inversion_calling_pipeline.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/06_inversions/inversion_calling_pipeline.sh) | Feifei Zhou |
| | Bionano validation | [`06_inversions/inversion_validation/bionano_validation.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/06_inversions/inversion_validation/bionano_validation.sh) | Feifei Zhou |
| | Hi-C inversion detection | [`06_inversions/inversion_validation/hic_inversion_detection.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/06_inversions/inversion_validation/hic_inversion_detection.py) | Feifei Zhou |
| | Population inversion frequency | [`06_inversions/population_inversion_freq.R`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/06_inversions/population_inversion_freq.R) | Feifei Zhou, Yafei Mao |
| **Complex Loci** | | | |
| | MHC structural haplotyping | [`07_complex_loci/07a_mhc/mhc_haplotyping.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/07_complex_loci/07a_mhc/mhc_haplotyping.py) | Quanyu Chen |
| | HLA/C4 annotation (Immuannot) | [`07_complex_loci/07a_mhc/hla_annotation_immuannot.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/07_complex_loci/07a_mhc/hla_annotation_immuannot.sh) | Quanyu Chen |
| | SMN block decomposition | [`07_complex_loci/07b_smn/smn_block_decomposition.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/07_complex_loci/07b_smn/smn_block_decomposition.py) | Dongya Wu |
| | SMN structural haplotypes (sHaps) | [`07_complex_loci/07b_smn/smn_structural_haplotypes.py`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/07_complex_loci/07b_smn/smn_structural_haplotypes.py) | Dongya Wu |
| | SMN phylogenetic tree | [`07_complex_loci/07b_smn/smn_phylogenetic_tree.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/07_complex_loci/07b_smn/smn_phylogenetic_tree.sh) | Dongya Wu |
| **Quality Control** | | | |
| | GCI continuity inspection | [`quality_control/gci_evaluation.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/quality_control/gci_evaluation.sh) | Quanyu Chen |
| | Merqury QV/CV calculation | [`quality_control/merqury_evaluation.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/quality_control/merqury_evaluation.sh) | Dongya Wu |
| | Flagger error detection | [`quality_control/flagger_evaluation.sh`](https://github.com/Asian-Pan-Genome/APGp1/blob/main/quality_control/flagger_evaluation.sh) | Dongya Wu |
---


---

### Direct Links to External Repositories

For your convenience, the following table provides direct links to the main repositories and tools used in this study (not developed by APG):

| Tool | Purpose | Repository |
|------|---------|------------|
| hifiasm | Genome assembly | https://github.com/chhylp123/hifiasm |
| Verkko | Genome assembly | https://github.com/marbl/verkko |
| Minigraph-Cactus | Pangenome graph construction | https://github.com/ComparativeGenomicsToolkit/cactus |
| vg | Graph mapping and variant calling | https://github.com/vgteam/vg |
| PanSVMerger | SV pruning (APG-developed) | https://github.com/Asian-Pan-Genome/PanSVMerger |
| Centromere annotation | Centromere boundary definition | https://github.com/Asian-Pan-Genome/Centromere |
| GCI | Assembly continuity inspection | https://github.com/Asian-Pan-Genome/GCI |
| Flagger | Assembly error detection | https://github.com/human-pangenomics/flagger |

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



