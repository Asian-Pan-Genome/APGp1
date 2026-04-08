[toc]

# Asian Pan-Genome project phase 1
Welcome to the repository for APG Phase 1 (APGp1). In this phase, we have generated a total of 320 de novo near-T2T assemblies from 160 East Asian (EAS) individuals.

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

### Assembly

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `01_assembly/gfasm.pl` | Gap-filling by integrating alternative assemblies (hifiasm-Hi-C, Verkko-trio) | backbone assembly (FASTA), query assemblies (FASTA) | gap-filled assembly (FASTA) | Dongya Wu | ✅ Added (was missing) |
| `01_assembly/gapfill_by_ont.sh` | Custom bash script for ONT-based gap-filling using yagcloser | draft assembly (FASTA), phased ONT reads (FASTQ) | gap-filled assembly (FASTA) | Dongya Wu, Chentao Yang | ✅ Added (was missing) |
| `01_assembly/polish_nextpolish2.sh` | Two-round polishing with NextPolish2 using HiFi and NGS reads | assembly (FASTA), HiFi reads (FASTQ), NGS reads (FASTQ) | polished assembly (FASTA) | Chentao Yang | ✅ Available |
| `01_assembly/manual_curation/` | Manual curation workflow for large structural errors | assembly (FASTA), T2T-CN1/CHM13 references | curated assembly (FASTA) | Dongya Wu | ✅ Available |

---

### Annotation

#### Repeatome

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `02_annotation/02a_repeatome/annotate_satellites.sh` | RepeatMasker + cenSat satellite annotation | assembly (FASTA) | repeat annotation (BED, OUT) | Jennifer | ✅ Available |
| `02_annotation/02a_repeatome/custom_satellite_filter.sh` | Custom bash script for filtering satellite annotations (lines 1519-1521 in Methods) | raw satellite BED | filtered satellite BED | Jennifer | ✅ Added (was missing) |

#### Centromere

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `02_annotation/02b_centromere/centromere_boundary_annotator.py` | Iterative boundary extension for centromere definition | αSat annotation (BED), satellite tracks (BED) | centromere/pericentromere regions (BED) | Jennifer | ✅ Available |
| `02_annotation/02b_centromere/run_centromere_analysis.sh` | Complete centromere annotation workflow | assembly (FASTA) | centromere size table, satellite composition | Jennifer | ✅ Available |

> **Note**: The centromere annotation repository ([Asian-Pan-Genome/Centromere](https://github.com/Asian-Pan-Genome/Centromere)) is now active.

#### rDNA

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `02_annotation/02c_rdna/rdna_haplotyping.py` | SNP-based rDNA haplotype classification (Hap0-Hap3) | rDNA copy sequences (FASTA) | haplotype assignment (TSV) | Lei Nie | ✅ Available |
| `02_annotation/02c_rdna/rdna_array_homogenization.py` | Local homogenization analysis of rDNA arrays | rDNA array sequences, ONT long reads | homogenization status (TSV) | Lei Nie | ✅ Available |

#### Gene

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `02_annotation/02d_gene/hybrid_annotation_pipeline.sh` | Complete hybrid gene annotation (Liftoff + Exonerate + Augustus) | assembly (FASTA) | gene annotation (GFF, GTF) | Quanyu Chen | ✅ Available |
| `02_annotation/02d_gene/liftoff_wrapper.sh` | Liftoff wrapper for GRCh38 annotation transfer | assembly (FASTA) | liftoff gene models (GFF) | Quanyu Chen | ✅ Available |
| `02_annotation/02d_gene/exonerate_augustus_filter.py` | Filtering ≥95% overlap between Exonerate and Augustus predictions | Exonerate GFF, Augustus GFF | filtered complementary genes (GFF) | Quanyu Chen | ✅ Available |


---

### SV Related

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `04_sv_related/04a_decomposition/PanSVMerger/pansvmerger.py` | Novel SV pruning algorithm to collapse similar paths | decomposed SVs (VCF), graph paths | non-redundant SVs (VCF) | Chentao Yang | ✅ Available |
| `04_sv_related/04b_merging/merge_sv_sets.sh` | SURVIVOR + bcftools merge strategy for SV integration | SV calls from multiple callers (VCF) | merged SV set (VCF) | Chentao Yang, Quanyu Chen | ✅ Available |
| `04_sv_related/04c_comparison/compare_sv_callers.py` | Compare pangenome-graph, assembly, and HiFi-based SV call sets | three SV call sets (VCF) | overlap statistics (TSV) | Chentao Yang | ✅ Available |
| `04_sv_related/04d_population_stratification/compute_hudson_fst.py` | Hudson *Fst* calculation for multi-allelic SV sites | SV allele frequency table | *Fst* values per SV site (TSV) | Chentao Yang | ✅ Available |
| `04_sv_related/04d_population_stratification/sv_allele_frequency.py` | Allele frequency calculation per SV site across populations | SV VCF, population metadata | allele frequency table (TSV) | Chentao Yang | ✅ Available |

> **Note**: The `SV-related` folder previously contained only one short script. It has now been expanded to include the full PanSVMerger pipeline, merging strategies, comparison workflows, and Fst calculation.

---

### Pangenome Graph

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `03_pangenome_graph/03a_construction/build_minigraph_cactus.sh` | Minigraph-Cactus (MC) graph construction | haplotype assemblies (FASTA), reference backbone (FASTA) | pangenome graph (GFA, GBZ) | Dongya Wu | ✅ Available |
| `03_pangenome_graph/03a_construction/graph_filtering.sh` | Allele frequency filtering using `vg clip -d N` | MC graph (GFA) | filtered graph (GFA) | Dongya Wu | ✅ Available |
| `03_pangenome_graph/03b_mapping/vg_giraffe_mapping.sh` | NGS short read mapping to MC graph | NGS reads (FASTQ), MC graph (GBZ) | aligned reads (GAF, BAM) | Qingyang Ni | ✅ Available |
| `03_pangenome_graph/03b_mapping/graphaligner_mapping.sh` | PacBio HiFi read mapping to MC graph | HiFi reads (FASTQ), MC graph (GFA) | aligned reads (GAF) | Qingyang Ni | ✅ Available |
| `03_pangenome_graph/03c_variant_calling/deepvariant_on_graph.sh` | DeepVariant variant calling from graph alignments | aligned reads (BAM), MC graph | small variants (VCF) | Qingyang Ni | ✅ Available |
| `03_pangenome_graph/03d_graph_comparison/compare_reference_backbones.py` | Compare T2T-CN1 vs T2T-CHM13-referenced graphs | two MC graphs | node/edge counts, variant overlap | Dongya Wu | ✅ Available |

---

### Loss-of-Function (pLoF)

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `05_loss_of_function/plof_annotation_vep.sh` | LOFTEE + VEP annotation for pLoF variants | variant VCF | annotated pLoF variants (VCF) | Anguo Liu | ✅ Available |
| `05_loss_of_function/plof_phasing_analysis.py` | Classify genes into single/multiple/compound LoF categories | pLoF variants with phasing info | gene category table (TSV) | Anguo Liu | ✅ Available |
| `05_loss_of_function/compound_plof_enrichment.R` | Enrichment analysis for tissue-specific and weakly constrained genes | gene categories, GTEx tau values, constraint metrics | enrichment statistics | Anguo Liu | ✅ Available |

---

### Inversions

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `06_inversions/inversion_calling_pipeline.sh` | PAV + SVIM-asm + LSGvar integration for inversion calling | haplotype assemblies (FASTA), reference (FASTA) | non-redundant inversion calls (BED) | Feifei Zhou | ✅ Available |
| `06_inversions/inversion_validation/bionano_validation.sh` | Bionano optical map validation for large inversions | Bionano contigs (XMAP), reference (FASTA) | validation report (TSV) | Feifei Zhou | ✅ Available |
| `06_inversions/inversion_validation/hic_inversion_detection.py` | Hi-C contact matrix analysis for inversion validation | Hi-C reads (FASTQ), reference (FASTA) | contact heatmap, inversion signal | Feifei Zhou | ✅ Available |
| `06_inversions/population_inversion_freq.R` | Fisher's exact test for population-stratified inversions | inversion calls, population metadata | stratified inversion list (TSV) | Feifei Zhou, Yafei Mao | ✅ Available |

---

### Complex Loci

#### MHC Region

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `07_complex_loci/07a_mhc/mhc_haplotyping.py` | Graph path extraction for HLA-A region structural haplotypes | MC graph (GFA), MHC coordinates | structural haplotype assignment (TSV) | Quanyu Chen | ✅ Available |
| `07_complex_loci/07a_mhc/hla_annotation_immuannot.sh` | Immuannot for HLA and C4 gene annotation | assembly (FASTA) | HLA/C4 annotation (GFF) | Quanyu Chen | ✅ Available |

#### SMN Region

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `07_complex_loci/07b_smn/smn_block_decomposition.py` | 8-block minimizer decomposition of SMN sequences | SMN locus sequences (FASTA) | block composition (TSV) | Dongya Wu | ✅ Available |
| `07_complex_loci/07b_smn/smn_structural_haplotypes.py` | sHap assignment based on block order/orientation | block composition (TSV) | structural haplotype (sHap) assignment (TSV) | Dongya Wu | ✅ Available |
| `07_complex_loci/07b_smn/smn_phylogenetic_tree.sh` | Maximum-likelihood phylogeny of SMN1/SMN2 genes | SMN gene sequences (FASTA) | phylogenetic tree (NWK) | Dongya Wu | ✅ Available |

---

### Quality Control

| Script | Purpose | Input | Output | Contact | Status |
|--------|---------|-------|--------|---------|--------|
| `quality_control/gci_evaluation.sh` | GCI continuity inspection for T2T-level assemblies | assembly (FASTA), HiFi/ONT reads | GCI score, gap report | Quanyu Chen | ✅ Available |
| `quality_control/merqury_evaluation.sh` | Merqury QV and CV calculation | assembly (FASTA), NGS/HiFi reads | QV, CV values | Dongya Wu | ✅ Available |
| `quality_control/flagger_evaluation.sh` | Flagger assembly error detection | assembly (FASTA), HiFi reads | error classification (duplicated/collapsed/erroneous) | Dongya Wu | ✅ Available |

---

### Summary Table of Key Resources

| Category | Script/Workflow | Repository Location | Contact |
|----------|-----------------|---------------------|---------|
| Gap-filling (missing script) | `gfasm.pl` | `01_assembly/gfasm.pl` | Dongya Wu |
| Gap-filling (missing script) | `gapfill_by_ont.sh` | `01_assembly/gapfill_by_ont.sh` | Dongya Wu, Chentao Yang |
| Centromere (missing repo) | `centromere_boundary_annotator.py` | https://github.com/Asian-Pan-Genome/Centromere | Jennifer |
| SV pruning (novel algorithm) | `PanSVMerger/pansvmerger.py` | `04_sv_related/04a_decomposition/PanSVMerger/` | Chentao Yang |
| SV merging | `merge_sv_sets.sh` | `04_sv_related/04b_merging/` | Chentao Yang, Quanyu Chen |
| SV comparison | `compare_sv_callers.py` | `04_sv_related/04c_comparison/` | Chentao Yang |
| Hudson *Fst* | `compute_hudson_fst.py` | `04_sv_related/04d_population_stratification/` | Chentao Yang |
| MHC haplotyping | `mhc_haplotyping.py` | `07_complex_loci/07a_mhc/` | Quanyu Chen |
| SMN block decomposition | `smn_block_decomposition.py` | `07_complex_loci/07b_smn/` | Dongya Wu |

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


## **Companion Papers & Specialized Repositories**

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



