# Inversion calling

Inversion are called using three assembly-based tools: PAV, SVIM-ASM, and LGvar.

## 1. [PAV](https://github.com/EichlerLab/pav) v2.4.6 
### two files
```Bash
#assemblies.tsv:
NAME    HAP1    HAP2
SAMPLE  SAMPLE.hap1.fa  SAMPLE.hap2.fa
```
```Bash
#config.json:
{
    "reference":"chm13v2.0.fa"
}
```
```Bash
#run command:
singularity run --bind "$(pwd):$(pwd)" library://becklab/pav/pav:latest -c 16
```

## 2. [SVIM-asm](https://github.com/eldariont/svim-asm) v1.0.3 
```Bash
minimap2 -t 12 -a -x asm20 --secondary=no --eqx -K 8G -s 1000 --cs -r2k chm13v2.0.fa SAMPLE.hap1.fa > SAMPLE.hap1.sam
minimap2 -t 12 -a -x asm20 --secondary=no --eqx -K 8G -s 1000 --cs -r2k chm13v2.0.fa SAMPLE.hap2.fa > SAMPLE.hap2.sam
samtools sort -m4G -@4 -o SAMPLE.hap1.sorted.bam SAMPLE.hap1.sam
samtools sort -m4G -@4 -o SAMPLE.hap2.sorted.bam SAMPLE.hap2.sam
samtools index SAMPLE.hap1.sorted.bam
samtools index SAMPLE.hap2.sorted.bam
svim-asm diploid ./ SAMPLE.hap1.sorted.bam SAMPLE.hap2.sorted.bam chm13v2.0.fa
```

## 3. [LGvar](https://github.com/YafeiMaoLab/LGvar) v1.1.0 
```Bash
LGVAR run -r chm13v2.0.fa \
    -q1 SAMPLE.hap1.fa \
    -q2 SAMPLE.hap2.fa \
    -cp1 SAMPLE.hap1.pair.tsv \
    -cp2 SAMPLE.hap2.pair.tsv \
    -cen chm13v2.0.cen.tsv \
    -telo chm13v2.0.telo.tsv \
    -m cts \
    -v inv \
    -s SAMPLE
```

* Note: Only large inversions >10 kbp are analyzed in the current paper.

