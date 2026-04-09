# Genome Assembly Polish Pipeline

This pipeline is designed for polishing genome assembly results, focusing on correcting structural variants (SV) and small variants (SNV/Indel).

## Pipeline Overview

The Polish pipeline consists of four main stages:

1. **Sequencing Data Mapping** - Align ONT and HiFi reads to the draft genome
2. **Structural Variant Detection and Correction (SV Polish)** - Detect and correct structural variants
3. **First Round Small Variant Correction (NextPolish2 R1)** - First round of base-level correction using NextPolish2
4. **Second Round Small Variant Correction (NextPolish2 R2)** - Second round of base-level correction using NextPolish2

```
draft.fasta
    │
    ├──► ONT Mapping ──┐
    │                   ├──► SV Polish ──► NextPolish2 R1 ──► NextPolish2 R2 ──► final_polished.fasta
    └──► HiFi Mapping ─┘
```

## Main Scripts

### Main Pipeline Script

| Script | Description |
|--------|-------------|
| `src/polish.sh` | Main pipeline script that orchestrates the entire polish workflow |

### Helper Scripts

| Script | Description |
|--------|-------------|
| `src/ont_mapping.sh` | Map ONT reads to the reference genome |
| `src/hifi_mapping.sh` | Map HiFi reads to the reference genome (basic version) |
| `src/hifi_mapping_filt.sh` | Map HiFi reads with clipping filter |
| `src/svPolish_shell.sh` | Structural variant detection and correction |
| `src/nextpolish_shell.sh` | NextPolish2 small variant correction |
| `src/filterClipForBam.py` | BAM file filtering tool |
| `src/keep_INDELs_DUP_homo.py` | VCF filtering tool |
| `filter_vcf.pl` | VCF file comparison and filtering tool |

## Usage

### Prerequisites

1. Prepare the `init.conf` configuration file with the following variables:
   - `DATA`: Data directory path
   - `SGE_PARTITION`: SLURM partition name
   - `REFERENCE`: Reference genome path
   - `ONT`: ONT data root directory
   - `HIFI`: HiFi data root directory
   - `YAK`: YAK k-mer database directory
   - `SJM`: SLURM job manager path
   - `WINNOWMAP`: Winnowmap software path
   - `NEXTPOLISH`: NextPolish2 software path
   - `SGE_THREADS1`, `SGE_THREADS2`: Thread count configuration
   - `SGE_MEM`: Memory configuration
2. Prepare input data:
   - Draft genome FASTA file
   - HiFi reads (after CCS processing)
   - ONT reads (already phased)
   - YAK k-mer databases (k21.yak, k31.yak)

### Running the Pipeline

```bash
bash src/polish.sh <sampleID> <hap> <draft.fasta>
```

Parameters:
- `sampleID`: Sample ID (e.g., HG001)
- `hap`: Haplotype, choose `Mat` (maternal) or `Pat` (paternal)
- `draft.fasta`: Path to the draft genome to be polished

### Example

```bash
cd polish_workdir
bash /path/to/polish/src/polish.sh HG001 Mat /data/HG001.draft.fasta
```

## Pipeline Details

### 1. Mapping Stage

Generates alignment result files:
- `ont2asm.ont.sort.filt_clip.bam` - ONT reads alignment
- `hifi2asm.hifi.sort.filt_clip.bam` - HiFi reads alignment

Uses Winnowmap for alignment, with meryl-built k=15 repetitive sequence index to filter repetitive regions.

### 2. SV Polish Stage

Structural variant detection and correction workflow:

1. Use Sniffles2 to detect SVs from HiFi and ONT alignment results separately
2. Use custom scripts to filter VCF, keeping homozygous INDELs and DUPs
3. Use Jasmine + Iris to merge and refine SV detection
4. Use bcftools consensus to apply SV corrections to the genome

Output file: `Iris_jasmine.hifi_ont.sniffles.polished.fasta`

### 3. NextPolish2 R1 Stage

First round of small variant correction:

1. Map HiFi reads to the SV-corrected genome
2. Use NextPolish2 for base-level correction (using k21 and k31 yak indexes)

Output file: `sv_polished.np_1st.fasta`

### 4. NextPolish2 R2 Stage

Second round of small variant correction:

1. Map HiFi reads to the first-round corrected genome
2. Use NextPolish2 for second-round base-level correction

Output file: `sv_polished.np_2nd.fasta` (final result)

## Output Directory Structure

```
workdir/
├── mapping/                          # Alignment results directory
│   ├── ont2asm.ont.sort.filt_clip.bam
│   ├── hifi2asm.hifi.sort.filt_clip.bam
│   └── mapping.finish               # Completion marker file
├── sv/                               # SV correction directory
│   ├── Iris_jasmine.hifi_ont.sniffles.polished.fasta
│   └── svPolish.finish
├── np2_r1/                           # First round NextPolish
│   ├── sv_polished.np_1st.fasta
│   └── nextPolish_r1.finish
└── np2_r2/                           # Second round NextPolish
    ├── sv_polished.np_2nd.fasta      # Final polish result
    └── nextPolish_r2.finish
```

## Software Dependencies

| Software | Purpose | Recommended Version |
|----------|---------|---------------------|
| Winnowmap | Long-read alignment | ≥2.03 |
| Samtools | BAM file processing | ≥1.14 |
| Sniffles2 | Structural variant detection | ≥2.0 |
| Jasmine | SV merging and refinement | - |
| Iris | SV refinement | - |
| Bcftools | VCF processing | ≥1.14 |
| NextPolish2 | Small variant correction | - |
| Meryl | k-mer counting | - |
| YAK | k-mer index building | - |
| Python3 | Script execution | ≥3.8 |
| Perl | Script execution | ≥5.10 |

## Resource Requirements

| Stage | CPU | Memory | Time |
|-------|-----|--------|------|
| Mapping | 48 threads | 50GB | ~4-6h |
| SV Polish | 16 threads | 30GB | ~2-3h |
| NextPolish2 R1 | 2 threads | 100GB | ~6-8h |
| NextPolish2 R2 | 2 threads | 100GB | ~6-8h |

## Notes

1. **Checkpoint/Resume**: The pipeline uses `.finish` marker files to track completion status of each stage, supporting checkpoint and resume functionality
2. **SLURM Support**: The pipeline uses SJM (SLURM Job Manager) to submit jobs, requiring a pre-configured SLURM environment
3. **k-mer Index**: Uses meryl to build k=15 repetitive sequence index for Winnowmap to filter repetitive regions
4. **Data Paths**: Ensure data paths configured in `init.conf` are correct, especially the `ONT` and `HIFI` directory structures

## Changelog

| Date | Version | Updates |
|------|---------|---------|
| 2024 | v1.0 | Initial version, integrated ONT+HiFi polish pipeline |
