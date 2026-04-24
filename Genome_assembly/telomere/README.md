# Telomere Analysis Pipeline

This directory contains scripts for telomere identification, validation, and completion in phased diploid genome assemblies (Mat/Pat).

## Files

| File | Description |
|------|-------------|
| `telomere_identify_shell.sh` | Generate SLURM job script to identify telomeres genome-wide using `tidk` |
| `telomere_complete.sh` | Search for telomeric sequences in small unanchored contigs from raw assemblies |
| `artifical_makeup_telo.sh` | Detect missing telomeres and artificially extend them with TTAGGG repeats |
| `makeChrEndBed.py` | Generate BED regions for chromosome ends (head/tail) from FASTA index |
| `tidk2teloRegion.py` | Convert `tidk` windowed search results to BED format with coverage filtering |
| `detect_wrongTelo.py` | Detect misassembled telomeres near gaps and output trim coordinates |
| `makeupMissedTelo.py` | Add artificial telomere repeats to chromosome ends and separate chr/unanchored sequences |
| `removeunAnchored.py` | Split a FASTA into canonical chromosomes, mitogenome, and unanchored contigs |
| `init.conf` | Configuration file for software paths, SLURM settings, and Conda environments |

## Dependencies

- `tidk` (v0.2.0) — telomeric repeat identification
- `samtools` — FASTA indexing
- `bedtools` — coverage and merge operations
- `python3`
- `fastaKit` (custom) — FASTA filtering by length/name
- `unimap` — alignment of candidate telomeric contigs to reference
- SLURM workload manager

## Configuration (`init.conf`)

```bash
SGE_PARTITION="cpu64,cpu128"
TELO_MEM=4g
SGE_THREADS=1

PYTHON=/path/to/python3
SAMTOOLS=/path/to/samtools
BEDTOOLS=/path/to/bedtools
ACTIVATE=/path/to/conda/activate
TIDK_ENV=tidk
```

## Usage

### 1. Identify telomeres genome-wide

Generate and submit a SLURM job to run `tidk` on the full assembly:

```bash
sh telomere_identify_shell.sh <id> <Mat|Pat> <genome.full.fa> <genome.chr.fa>
sbatch <generated_script>
```

**Outputs:**
- `<id>_<hap>.full.telomere_200_0.5.bed` — telomere regions
- `<id>_<hap>.full.telomere.200_0.5_m300.bed` — merged regions
- `<genome.chr>.teloMiss.txt` — chromosome ends with low telomere coverage (<0.5)

### 2. Find telomeres in unanchored small contigs

For assemblies where telomeres may be trapped in small contigs:

```bash
sh telomere_complete.sh <ID> <Mat|Pat> <DRAFT_ASSEMBLY>
```

This searches raw verkko and hifiasm contigs (<1 Mb) for telomeric repeats and maps candidates to the CHM13 telomere reference to validate them.

### 3. Detect wrong telomere assemblies

If telomeres are assembled too close to gaps (<3000 bp) at chromosome ends, trim them:

```bash
python3 detect_wrongTelo.py <genome.fa.fai> <gaps.bed> <telomere.bed> > teloTrim.bed
```

### 4. Artificially complete missing telomeres

For chromosome ends lacking telomeres, extend with TTAGGG repeats:

```bash
sh artifical_makeup_telo.sh   # (embedded in larger pipeline; see below)
# Or directly:
python3 makeupMissedTelo.py <teloMiss.txt> <genome.fa> <out_prefix>
```

**Outputs:**
- `<out_prefix>.teloRefine.fasta` — chromosomes with extended telomeres
- `<out_prefix>.unAnchored.fa` — unanchored contigs
- `<out_prefix>.chrID.map` — original to new name mapping

### 5. Clean up and rename final assembly

Separate chromosomes, mitogenome, and unanchored sequences with canonical naming:

```bash
python3 removeunAnchored.py <genome.fa> <out_prefix>
```

**Outputs:**
- `<out_prefix>.chr.fasta` — canonical chromosomes (chr1–chr22, chrX, chrY, chrM)
- `<out_prefix>.mitogenome.fa` — mitochondrial sequence
- `<out_prefix>.unAnchored.fa` — remaining unanchored contigs
- `<out_prefix>.chrID.map` — name mapping

## Helper Scripts

### `makeChrEndBed.py`

Generate BED intervals for chromosome ends:

```bash
python3 makeChrEndBed.py <genome.fa.fai> <end_size> > genome.end.bed
```

### `tidk2teloRegion.py`

Convert `tidk` CSV output to filtered BED:

```bash
python3 tidk2teloRegion.py <tidk_windows.csv> [coverage_cutoff] > telomere.bed
```

Default cutoff is 0.5 (50% telomeric repeat coverage per window).

## Pipeline Overview

The typical telomere completion workflow:

1. **Identify** telomeres on the full assembly (`telomere_identify_shell.sh`)
2. **Check** for missing ends (`teloMiss.txt`)
3. **Search** raw small contigs for alternative telomeric sequences (`telomere_complete.sh`)
4. **Detect** misassemblies near gaps (`detect_wrongTelo.py`)
5. **Complete** missing telomeres artificially (`makeupMissedTelo.py`)
6. **Clean** and output canonical chromosomes (`removeunAnchored.py`)

## Notes

- Telomere repeat pattern is hardcoded as `TTAGGG` (vertebrate canonical repeat).
- Coverage thresholds (0.5–0.6) and distance cutoffs (3000 bp) can be adjusted in the respective scripts.
- The pipeline assumes human chromosome naming (`chr1`–`chr22`, `chrX`, `chrY`, `chrM`).
