# Centromere Annotation and Analysis

This repository contains the centromere annotation pipeline (see [Centromere repository](https://github.com/Asian-Pan-Genome/Centromere)) and analysis and plotting scripts for centromere completeness, centromere size, and satellite length comparison.

---

## 🔗 Centromere Pipeline & Annotation

The centromere identification pipeline and genomic annotation files are maintained in a dedicated repository:

**👉 [Asian-Pan-Genome/Centromere](https://github.com/Asian-Pan-Genome/Centromere)**

This includes:
- Complete centromere coordinates
- Detailed satellite and Higher-Order Repeat (HOR) annotation tracks
- Robust pipelines for HOR identification and satellite annotation

---

##  Analysis Scripts

The following scripts contribute to the comparative analyses described in the associated publication.

| Figure | Description |
|---|---|
| **Main Figure** | Centromere size distribution across chromosomes in APGp1 |
| **Supplementary Figure** | Satellite length and centromere completeness statistics |
| **Supplementary Figure** | Chr9 centromere size and satellite length across super-populations |

---
##  Repeat & Transposable Element Annotation

Repeat and transposable elements were identified using **RepeatMasker (v4.1.2)** with the **Dfam (v3.3)** database. The analysis was run in sensitive mode (`-s`) with the human species library and the RMBlast search engine:


**Command:**

```bash
repeatmasker \
  -species human \
  -e rmblast \
  -s \
  -pa 30 \
  $fullfa \
  -html -gff \
  -dir $outdir
```
##  Contact

For questions about the analysis scripts, please open an [issue](../../issues) in this repository.  
For questions about the pipeline or annotation files, please visit the [Centromere repository](https://github.com/Asian-Pan-Genome/Centromere
