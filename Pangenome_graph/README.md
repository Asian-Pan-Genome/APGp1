# Graph Construction and Evaluation

This repository includes the commands and workflows in pangenome graph analysis, including `construction` and `evaluation` (**graph quality assessment, reference bias evaluation and multiple pangenome graphs comparison**).


## Graph Construction

Multiple graphs are built from different assemblies using multiple reference backbones (T2T-CHM13, T2T-CN1 and GRCh38) using two methods. All the related pangenome graphs are available at the APG [portal](https://github.com/Asian-Pan-Genome/APGp1#pangenome-graphs)

### Minigraph-Cactus (MC) Graph
We constructed the **Minigraph-Cactus (MC)** pangenome graphs using `Minigraph-Cactus` (v2.8.2; [Hickey et al., 2023](https://www.nature.com/articles/s41587-023-01793-w)). The construction was executed with the following command:

```shell
cactus-pangenome ./js APGp1.list \
    --outDir ./APGp1 \
    --outName APGp1-MC-CN1v1 \
    --reference CN1v1 \
    --gbz --giraffe --vcf --chrom-vg \
    --maxCores 70 --maxMemory 2500G \
    --workDir ./APGp1-WD
```
The input file `APGp1.list` contains the assembly paths, where the first column specifies the **Sample ID** and the second column provides the **absolute path** to the corresponding assembly.

#### Stability of Construction Order:
Since the order of samples in the input list dictates the incremental construction process in `Minigraph-Cactus`, we evaluated the potential impact of sequence ordering. We performed a **permutation test** by randomly selecting 10 assemblies and shuffling their input order across 10 independent iterations. Our results indicate that while minor variations exist, the technical variance introduced by the construction order is negligible compared to other factors such as reference bias (see Figure below).

![Permutation Test for Minigraph-Cactus](./PermutationTest.png)

### Minigraph (MG) Graph

In parallel, we generated **Minigraph (MG)** graphs using `minigraph` (v0.21-r606; [Li et al., 2020](https://pmc.ncbi.nlm.nih.gov/articles/PMC7568353/)) to capture structural variation backbones. The graphs were built using the following command:

```shell
minigraph -cxggs -t${threads} ${ref} ${asm1} ${asm2} ...
```
## Graph Evaluation
### Graph Quality Assessment
This repository contains the pipelines for mapping short/long reads to the **APGp1 Minigraph-Cactus (MC)** pangenome graphs and performing graph-based small variant calling.

#### 1. Graph Mapping
We utilize different aligners depending on the sequencing technology to map reads back to the pangenome graph.
##### Short-read (NGS) Alignment
NGS short reads were aligned to the **T2T-CN1-referenced MC graph** using `vg giraffe` (v1.56.0).
+ **Command:**
  ```shell
  vg giraffe -Z ${pref}.gbz -m ${pref}.min -d ${pref}.dist \
           -p -f ${h1} -f ${h2} -t ${threads} \
           --sample ${sample} \
           --read-group "ID:1 LB:lib1 SM:${sample} PL:illumina PU:unit1" \
           -o BAM > ${sample}.bam
  ```
+ **Post-processing:** Reads with no alignment or an aligned fraction < 99% were filtered. For downstream variant calling, the BAM output was processed to remove the reference prefix (e.g., `CN1v1#0#`) to ensure compatibility with standard tools.

##### Long-read (PacBio HiFi) Alignment
HiFi reads were aligned using `GraphAligner` (v1.0.17) with the `-x vg` preset.

+ **Filtering Criteria:** 
  + Keep only the highest-scoring alignment per read (based on AS value).
  + Discard reads with < 80% length aligned.
  + Remove alignments with MAPQ < 1.
  + Exclude alignments with identity < 90%.





### Reference Bias Evaluation



### Multiple Pangenome Graphs Comparison