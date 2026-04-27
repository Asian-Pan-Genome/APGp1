# QC
Many QC assessments were performed, including:
- Basic stats: Genome size, N50/auN, T2T contigs number, compleasm/asmgene
- K-mer based: merquery QV/CV, yak switch/hamming error, VerityMap 
- Alignment-based: GCI, Flagger


## Basic stats
### Requirements
- Biopython
- compleasm
- minimap2
- paftools.js

### Run

Before running, please prepare:
- Primates BUSCO OrthoDB (see details from [compleasm](https://github.com/huangnengCSU/compleasm))
  - replace the line:
    https://github.com/Asian-Pan-Genome/APGp1/blob/03f917fdbd4d2016528f9765e771a44b492f396a/QC/src/asm_stats.sh#L46
    
- Ensembl gene cDNA sequences (not provided)
  - replace the line:
    https://github.com/Asian-Pan-Genome/APGp1/blob/03f917fdbd4d2016528f9765e771a44b492f396a/QC/src/asm_stats.sh#L68
- Reference (e.g., CHM13v2, CN1v1) gene alignments (not provided)
  - replace the line:
    https://github.com/Asian-Pan-Genome/APGp1/blob/d7c082d0231299f68cec1a9646f3648d9f789789/QC/src/asm_stats.sh#L72

Then, just run
```shell
bash src/asm_stats.sh $sample $hap $version ${sample}_$hap.$version.fasta $threads" # feel free to delete the $version argument in the script
```



## K-mer based
### merquery QV/CV
### yak switch/hamming error
### VerityMap

## Alignment-based
### GCI
See details in [GCI repo](https://github.com/yeeus/GCI).
### Flagger
