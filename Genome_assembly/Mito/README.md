# Mitogenome Assembly Pipeline

This directory contains scripts for mitochondrial genome (mitogenome) extraction, assembly, and validation from phased diploid genome assemblies (Mat/Pat).

## Files

| File | Description |
|------|-------------|
| `MitoAsm.sh` | Main workflow for batch mitogenome assembly and processing |
| `mitoFound.sh` | Extract mitogenomes from existing Mat/Pat assembly results |
| `MitoCutter.py` | Cut and orient abnormally assembled mitogenomes into complete circular sequences |
| `hifi2mito_shell.sh` | Generate SLURM job script to map HiFi reads to mitochondrial reference |

## Dependencies

- `minimap2` — read/assembly alignment
- `python3` with `Biopython`
- `MitoZ` (optional, for de novo mitogenome assembly)
- `LINKVIEW.py` — alignment visualization
- SLURM workload manager (for job submission)

A configuration file `init.conf` is required in the same directory. It should define:

```bash
HIFI=/path/to/hifi_reads          # HiFi read directory
MINIMAP2=/path/to/minimap2        # minimap2 binary
MITO_REF=/path/to/NC_012920.1.fasta  # Human mitochondrial reference (rCRS)
```

## Usage

### 1. Find mitogenomes from phased assemblies

After Mat and Pat genome assemblies are complete, run:

```bash
sh mitoFound.sh assembly.both_done.list
```

This script will:
- Check if mitogenome exists in `Mat/telomere/` or `Pat/telomere/`
- Copy the mitogenome to `Mito/$ID.mitogenome.fasta`
- If both Mat and Pat have mitogenomes, compare MD5 checksums
- Align to reference, cut/ orient, and generate dotplot visualization

### 2. Assemble mitogenome from HiFi reads (fallback)

For samples where no mitogenome was found in the phased assemblies, map HiFi reads to the reference:

```bash
sh hifi2mito_shell.sh <sample_ID>
sbatch hifi2mito.sh
```

Then assemble with MitoZ or other assemblers if sufficient reads are mapped.

### 3. Batch workflow (integrated)

`MitoAsm.sh` provides an integrated batch workflow:

```bash
sh MitoAsm.sh
```

Steps include:
1. Check which samples have both Mat and Pat assemblies done
2. Run `mitoFound.sh` to extract existing mitogenomes
3. For samples without mitogenome, check HiFi mapping depth
4. Trigger de novo assembly if enough HiFi reads are available
5. Post-process all assemblies with `MitoCutter.py` and visualize

## MitoCutter.py

Cut and orient mitochondrial genome assemblies based on alignment to the reference.

```bash
python3 MitoCutter.py <mito.fa> <mito2ref.paf> <out_prefix>
```

**Output:**
- `<out_prefix>.fasta` — cleaned, oriented mitogenome sequence

**Logic:**
- Single alignment: trim to the aligned region
- Two alignments (split assembly): stitch segments in correct order to reconstruct the circular molecule

## Directory Structure (per sample)

```
<sample_ID>/
├── Mat/telomere/<ID>_Mat.v3.mitogenome.fa
├── Pat/telomere/<ID>_Pat.v3.mitogenome.fa
└── Mito/
    ├── <ID>.mitogenome.fasta        # raw extracted sequence
    ├── ori2ref.paf                  # alignment to reference
    ├── <ID>.mitogenome.final.fasta  # cleaned and oriented
    └── final2ref.paf                # final alignment for QC
```

## Notes

- The pipeline assumes human mitochondrial reference `NC_012920.1` (rCRS).
- A size threshold of ~17 kb is used to distinguish single-copy vs. multi-copy mitogenome assemblies.
- Mitochondrial genome is haploid; if Mat and Pat copies are identical, only one is kept.
