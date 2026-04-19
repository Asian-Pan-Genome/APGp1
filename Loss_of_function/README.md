# pLoF Variant Analysis Pipeline

## Overview
This repository provides a reproducible pipeline for identifying and analyzing **putative loss-of-function (pLoF) variants** using both **pangenome graph-based** and **NGS-based** approaches. The workflow includes variant normalization, functional annotation, benchmarking, and downstream gene-level analyses.

---

## 1. Graph-based pLoF Variant Calling

We constructed **pangenome graphs** using GRCh38 as the backbone and generated **per-sample private variant calls** for APGp1 individuals.

### Variant processing

Multi-sample VCFs were decomposed into per-sample variants and normalized:

```bash
bcftools view -a -I -s $sample -c 1:nref
```

```bash
bcftools norm -c s -f reference.fasta -m -any
```

```bash
rtg vcfdecompose --break-mnps --break-indels
```

### Functional annotation

pLoF variants were annotated using:

- VEP (Ensembl v112)  
- LOFTEE plugin  

We retained **high-confidence (HC) pLoF variants**:
- ≤ 50 bp  
- annotated as `LoF=HC`  

Variants were further annotated against **gnomAD v4.1**.

---

## 2. Benchmarking with HG002

We evaluated performance using the **HG002 GIAB v4.2.1 benchmark set**.

- Comparison tool: `rtg vcfeval`  
- Manual validation:
  - Short-read (NGS) alignments  
  - Long-read (PacBio HiFi) alignments  
  - Visualization in IGV  

### Curation flags

Private pLoF variants were annotated as potential artifacts based on:

- Variant type (stop-gain, frameshift, splice)  
- Context:
  - MNP  
  - low-complexity regions (LCR)  
  - reference assembly errors  
  - ambiguous alignments  

---

## 3. NGS-based pLoF Calling and Comparison

For comparison, pLoF variants were independently called from **30× NGS data**:

- Alignment: `bwa mem`  
- Variant calling: GATK joint calling  
- Filtering:
  - VQSR  
  - VariantFiltration  

### Cross-method comparison

Shared variants between graph-based and NGS-based calls were identified using:

- `rtg vcfeval`  
- `bcftools isec`  

### Filtering criteria

To reduce false positives:

- Missing rate < 5%  
- Allele frequency ≤ 0.95  
- Exclusion of low-complexity regions  
- Exact allelic match between callsets  

---

## 4. Gene Classification by pLoF

Genes were categorized based on pLoF variant patterns:

- **Single heterozygous**  
- **Multiple heterozygous**  
- **Homozygous**  
- **Compound heterozygous**  

Compound category was further divided into:

- **Strict compound**: multiple heterozygous variants per allele  
- **Loose compound**: combination of heterozygous and homozygous variants  

---

## 5. Gene Constraint and Expression Specificity

### Constraint metrics

Gene essentiality was evaluated using:

- **pLI** (LoF intolerance)  
- **sₕₑₜ** (selection coefficient for heterozygous variants)  

Thresholds:

- LoF-tolerant: pLI ≤ 0.1  
- Strong constraint: sₕₑₜ ≥ 0.01  

### Tissue specificity

Expression specificity was assessed using **tau (τ)** from GTEx v8:

- τ ranges from 0 (ubiquitous expression) to 1 (tissue-specific)  
- High specificity defined as: τ ≥ 0.6  

---

## Summary

This pipeline integrates:

- Graph-based variant discovery  
- Functional annotation (LOFTEE)  
- Benchmark validation (HG002)  
- Cross-platform comparison (NGS vs graph)  
- Gene-level functional interpretation  

It provides a robust framework for studying **loss-of-function variation at population scale**.
