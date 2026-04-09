# Genome Gap Filling Pipeline

This pipeline is designed for filling gaps in genome assemblies, detecting and trimming telomere misassemblies, and performing quality control checks.

## Pipeline Overview

The gap filling workflow consists of multiple stages:

1. **Gap Region Extraction** - Extract gap positions and extend regions for analysis
2. **Visualization** - Generate BAM snapshots and JBrowse2 configuration for manual inspection
3. **Simple Gap Filling** - Use YAGCloser to fill gaps covered by spanning long reads
4. **Telomere Analysis** - Identify telomere regions and trim potential misassemblies
5. **Quality Assessment** - Calculate QV scores and check chromosome structure
6. **Manual Gap Analysis** - Identify imperfectly mapped reads for complex gap filling

```
draft.fasta + ONT reads
    │
    ├──► Gap Extraction ──► Visualization (bamsnap/jbrowse2)
    │
    ├──► YAGCloser ──► Simple Gap Filling ──► v2.fasta
    │
    ├──► Telomere Detection ──► Misassembly Trimming ──► v3.fasta
    │
    ├──► QV Assessment
    │
    ├──► Structure Check (vs CHM13)
    │
    └──► Manual Gap Fill Preparation (ONT all-vs-all alignment)
```

## Main Scripts

### Main Pipeline Script

| Script | Description |
|--------|-------------|
| `src/GapFill_mgf.sh` | Main pipeline script (MGF: Manual Gap Fill version) |

### Helper Scripts

| Script | Description |
|--------|-------------|
| `src/ont_mapping.sh` | ONT reads mapping to genome |
| `src/telomere_identify_shell.sh` | Identify telomere regions using tidk |
| `src/telomere_errorTrim_shell.sh` | Detect and trim telomere misassemblies |
| `src/structure_check.sh` | Map assembly to CHM13 for structure validation |
| `src/get_BadMapRead_shell.sh` | Extract imperfectly mapped reads |
| `src/ont_allvsall_shell.sh` | ONT reads all-vs-all alignment |
| `src/meryl_qv_shell.sh` | Calculate QV scores using meryl |
| `src/cutGap2reads.py` | Extract gap-flanking sequences as reads |
| `src/GCI.py` | Gap compression index calculation |

### Utility Scripts

| Script | Description |
|--------|-------------|
| `src/alignmentStatFromPaf.py` | Alignment statistics from PAF format |
| `src/MakeLinkViewKaryotypeFromPaf.py` | Generate karyotype files for visualization |

## Usage

### Prerequisites

1. Prepare `init.conf` configuration file with the following variables:
   - `DATA`: Data root directory
   - `MERYL_DB`: Meryl k-mer database directory
   - `REFERENCE`: CHM13 reference genome path
   - `SGE_PARTITION`: SLURM partition name
   - `SJM`: SLURM job manager path
   - `WINNOWMAP`: Winnowmap software path
   - `SAMTOOLS`: Samtools path
   - `MINIMAP2`: Minimap2 path
   - `ACTIVATE`, `TIDK_ENV`: Conda activation and tidk environment
   - Other software paths as needed

2. Prepare input data:
   - Draft genome FASTA file (scaffold level)
   - ONT reads mapped to draft genome (sorted BAM)
   - Meryl k-mer databases for QV calculation

### Running the Pipeline

```bash
bash src/GapFill_mgf.sh <sampleID> <hap> <ont2asm.sort.bam> <draft.fasta>
```

Parameters:
- `sampleID`: Sample ID (e.g., HG001)
- `hap`: Haplotype, choose `Mat` (maternal) or `Pat` (paternal)
- `ont2asm.sort.bam`: Sorted BAM file of ONT reads mapped to draft genome
- `draft.fasta`: Draft genome assembly file

### Example

```bash
cd gapfill_workdir
bash /path/to/GapFill/src/GapFill_mgf.sh HG001 Mat HG001_Mat-unknown_ONT.sort.bam HG001_Mat_scaffold.fasta
```

## Pipeline Details

### 1. Gap Region Extraction

Extracts gap positions from the draft genome and extends them by 20kb on both sides:

- Input: `${draft}.fasta`
- Output: `${draft}.gaps.bed`, `${draft}.gaps.ext.bed`, `${draft}.gaps.ext.maps`

Uses `gap2posBed.pl` to extract gap positions and `bedtools slop` to extend regions.

### 2. BAM Extraction and Visualization

Extracts BAM files around each gap region and generates visualization:

- Creates `bamsnap/` directory with PNG images for each gap
- Uses modified BAMSnap compatible with long-read alignments
- Generates JBrowse2 configuration for local inspection

### 3. Simple Gap Filling (YAGCloser)

Fills gaps that are covered by spanning long reads:

- Creates `yagcloser/` directory
- Uses `detgaps` (from asset) to generate gaps.bed
- Runs YAGCloser with parameters: `-pld 0.15 -f 100 -mins 2`
- Output: `${id}_${hap}.v2.fasta`

Note: This step can only fill simple gaps with clear spanning reads. Complex gaps remain unfilled.

### 4. Telomere Detection and Trimming

Identifies and trims potential telomere misassemblies:

#### Step 4.1: Telomere Identification
- Uses `tidk` to search for telomere motifs (TTAGGG)
- Parameters: window=200, coverage cutoff=0.5
- Merges regions within 300bp using `bedtools merge`
- Output: `${id}_${hap}.v2.telomere.200_0.5_m300.bed`

#### Step 4.2: Misassembly Detection and Trimming
- Uses `detect_wrongTelo.py` to identify problematic telomere assemblies
- Generates `teloTrim.edit.bed` with trimming instructions
- Updates assembly using `update_assembly_edits_and_breaks.py`
- Removes small contigs and generates chromosome-level FASTA
- Output: `${id}_${hap}.v3.chr.fasta`

#### Step 4.3: Missing Telomere Detection
- Re-runs telomere detection on trimmed assembly
- Identifies chromosomes with missing telomere coverage
- Output: `${id}_${hap}.v3.chr.fasta.teloMiss.txt`

### 5. Quality Assessment (QV)

Calculates assembly quality values using meryl:

- Creates `MGF/QV/` directory
- Uses `${id}.hybrid.meryl` k-mer database
- Output: QV statistics for the assembly

### 6. Structure Check

Maps assembly to CHM13 reference to validate chromosome structure:

- Creates `MGF/SCHECK/` directory
- Uses Winnowmap for alignment (asm10 preset)
- Generates:
  - PAF alignment files
  - Alignment statistics
  - LinkView visualization (SVG/PNG)
  - Dotplot PDFs

### 7. Manual Gap Fill Preparation

Prepares data for manual/complex gap filling:

#### Step 7.1: ONT Mapping
- Maps ONT reads to v3.chr.fasta using Winnowmap
- Creates `repetitive_k15.txt` index using meryl
- Output: `out2asm.ont.bam`

#### Step 7.2: Bad Read Extraction
- Extracts imperfectly mapped and clipped reads
- Filters out perfectly mapped reads
- Output: `imperfect_mapped.ont.fa`

#### Step 7.3: All-vs-All Alignment
- Checks if gaps still exist in the assembly
- Extracts gap-flanking regions as additional sequences
- Performs all-vs-all alignment of imperfect reads
- Output: `imperfect_read2read.paf`

This PAF file can be used for local assembly graph construction and manual gap filling.

## Output Directory Structure

```
workdir/
├── bamsnap/                          # BAM visualization images
│   ├── ${chr}_${start}-${end}.png
│   └── bamsnap.finish
├── jbrowse2/                         # JBrowse2 configuration
│   ├── contain_gaps.chrs.fasta
│   ├── contain_gaps.bam
│   └── ...
├── jbrowse2.tgz                      # Compressed JBrowse2 files
├── yagcloser/                        # Simple gap filling results
│   ├── output/
│   │   ├── ${id}_${hap}.edits.txt
│   │   ├── ${id}_${hap}.potential.fillable.gaps.txt
│   │   └── ${id}_${hap}.ambiguous.txt
│   ├── ${id}_${hap}.v2.fasta
│   └── yagcloser.finish
├── telomere/                         # Telomere analysis
│   ├── ${id}_${hap}.v2.fasta (link)
│   ├── ${id}_${hap}.v2.telomere.200_0.5_m300.bed
│   ├── ${id}_${hap}.v3.fasta
│   ├── ${id}_${hap}.v3.chr.fasta
│   ├── ${id}_${hap}.v3.chr.fasta.teloMiss.txt
│   └── tidk.v2.sh, tidk.v3.sh
└── MGF/                              # Quality assessment and manual fill
    ├── QV/                           # QV calculation
    │   ├── genome.fasta (link)
    │   └── qv.finish
    ├── SCHECK/                       # Structure check vs CHM13
    │   ├── ${ID}.map2ref.paf
    │   ├── ${ID}.map2ref.paf.stat
    │   ├── chr*/                     # Per-chromosome results
    │   │   ├── karyotype.txt
    │   │   ├── ${chr}.linkview.svg/png
    │   │   └── ${chr}.dotplot.pdf
    │   └── scheck.finish
    └── MANUAL_FILL/                  # Manual gap fill preparation
        ├── genome.fasta (link)
        ├── out2asm.ont.bam
        ├── repetitive_k15.txt
        ├── imperfect_mapped.ont.fa
        ├── imperfect_read2read.paf
        └── mapping.finish
```

## Output Genome Versions

| Version | File | Description |
|---------|------|-------------|
| v0 | `${id}_${hap}_scaffold.fasta` | Original input draft |
| v2 | `${id}_${hap}.v2.fasta` | After YAGCloser gap filling |
| v3 | `${id}_${hap}.v3.fasta` | After telomere trimming |
| v3.chr | `${id}_${hap}.v3.chr.fasta` | Chromosome-level (small contigs removed) |

## Software Dependencies

| Software | Purpose | Recommended Version |
|----------|---------|---------------------|
| BEDTools | Genome interval operations | ≥2.29 |
| Samtools | BAM file processing | ≥1.14 |
| Winnowmap | Long-read alignment | ≥2.03 |
| Minimap2 | Sequence alignment | ≥2.24 |
| Meryl | k-mer counting | - |
| YAGCloser | Gap filling | - |
| tidk | Telomere identification | - |
| BAMSnap | Alignment visualization | Modified version* |
| JBrowse2 | Genome browser | - |
| LinkView | Chromosome visualization | - |
| seqtk | FASTA/FASTQ processing | - |
| pigz | Parallel gzip | - |
| Perl | Script execution | ≥5.10 |
| Python3 | Script execution | ≥3.8 |

*Note: Use the modified BAMSnap version compatible with long-read alignments (not the original version from parklab).

## Resource Requirements

| Stage | CPU | Memory | Time |
|-------|-----|--------|------|
| Gap Extraction | 1 | 1GB | ~1min |
| BAM Extraction | 1 | 8GB | ~10-30min |
| YAGCloser | 1 | 4GB | ~1min |
| Telomere Detection | 1 | 4GB | ~5min |
| Structure Check | 24 | 35GB | ~1-2h |
| QV Calculation | 48 | 20GB | ~30min |
| ONT Mapping | 48 | 50GB | ~4-6h |
| All-vs-All Alignment | 24 | 100GB | ~2-4h |

## Notes

1. **Checkpoint/Resume**: The pipeline uses `.finish` marker files to track completion status, supporting checkpoint and resume functionality

2. **SLURM Support**: The pipeline uses SJM (SLURM Job Manager) to submit jobs for resource-intensive steps

3. **YAGCloser Limitations**: YAGCloser can only fill simple gaps with spanning reads. Complex gaps with ambiguous alignments will not be filled (see `${id}.ambiguous.txt`)

4. **Telomere Trimming**: Trimming is based on both gap positions and telomere signal. Trimmed sequences are kept in the output with `_TeloTrim` suffix

5. **Manual Gap Filling**: The MANUAL_FILL stage prepares data for complex gap filling that requires manual inspection or specialized tools

6. **JBrowse2 Visualization**: Generate `jbrowse2.tgz` for downloading and local inspection using JBrowse2

## Additional Documentation

- `local_jbrowse2.md` - Guide for setting up local JBrowse2
- `Pipeline_TEST1.md` - Basic pipeline testing guide
- `Pipeline_TEST2.md` - Advanced pipeline testing guide
- `Pipeline_trimAndFill.md` - Detailed trim and fill workflow
- `process.md` - Process documentation
- `resources.md` - Resource requirements and configurations
- `deploy_pipeline.md` - Deployment instructions

## Author and Maintenance

- Author: Yang Chentao
- Affiliation: Life Sciences Institute, Zhejiang University
- Email: yangchentao@zju.edu.cn

## Changelog

| Date | Version | Updates |
|------|---------|---------|
| 2024 | v1.0 | Initial MGF (Manual Gap Fill) pipeline version |
