# Gene Annotation
<img width="1532" height="1823" alt="903ca1e768a7529a7d10a89acdb74291" src="https://github.com/user-attachments/assets/582c486f-858e-40e5-8f09-1650f8931028" />

**Workflow for gene annotation.** Three annotation approaches are recruited, including liftover from GRCh38.p14 annotation, homology search and de novo prediction.

*This pipeline borrowed from [Yang et al.](https://www.nature.com/articles/s41422-023-00849-5), and has been imporved upon it.*

## Requirements
- Rerference gene set: GRCh38 Refseq gene annotation / Ensembl (Gencode) gene annotation
- liftoff
- RepeatMasker
- UniProtKB/Swiss-Prot protein sequences
- Exonerate
- Augustus
- AGAT
- blastp
- gffread
- interproscan (optional for functional annotation)

## Pipeline
### Liftover gene annotations using `liftoff` from reference gene set to indivial genome assemblies
```bash
# One can choose either whole-genome level or chromosome level liftoff
## whole-genome level
liftoff $asm.fa $hg38.fa -sc 0.95 -copies -g $hg38.gff -polish -o $asm.liftoff.gff -exclude_partial

## chromosome level
### Before liftover, one can select the corresponding chromosome (and the rest scaffolds and patches) from refernce annotation
liftoff $asm.chrom.fa $hg38.chrom.fa -sc 0.95 -copies -g $hg38.chrom.gff -polish -o $asm.chrom.liftoff.gff -exclude_partial
```

### Homology searching with UniProtKB/Swiss-Prot protein sequences
```bash
# For protein alignment, please repeatmasking assemblies first
exonerate --model protein2genome --showvulgar no --showalignment no --showquerygff no --showtargetgff yes --softmasktarget yes --percent 80 --targetchunkid 1 --targetchunktotal 100 -q uniprot_sprot.fasta -t $asm.rm.fa > exonerate.out
agat_convert_sp_gxf2gxf.pl -g exonerate.out -o exonerate.out.gff3
```

### De novo gene prediction using `Augustus`
```bash
# Also, please use the repeatmasked assmebly
augustus --species=human --gff3=on $asm.rm.fa > augustus.out
agat_convert_sp_gxf2gxf.pl -g augustus.out -o augustus.out.gff3
```

### Final integration (and functional annotation)
Final annotation = liftoff (backbone) + augustus_exonerate (complementary)
```bash
# Combine augustus and exonerate
## 95% overlapping rate was set
python scripts/merge_augustus_exonerate.py augustus.out.gff3 exonerate.out.gff3 0.95 augustus_exonerate augustus_exonerate
agat_convert_sp_gxf2gxf.pl -g augustus_exonerate.gff -o augustus_exonerate.sort.gff

# To combine liftoff and augustus_exonerate, we define the gene regions annotated by liftoff as backbone and append augustus_exonerate gene set to the mssing regions
## Before merging, one should select wanted regions like gene and pesudogenes
## Here, we exlude non-coding RNA elements (in the case of Refseq gene annotation)
cat scripts/gene_biotype.list | grep -f <(echo -e 'protein_coding\npseudogene') | grep -v 'RNA' | while read -r type; do
    grep "gene_biotype=$type" $asm.liftoff.gff >> $asm.liftoff.gene_pseudogene.gff
done

# Next, get the nonoverlapped augustus_exonerate gene set
bedtools intersect -v -a <(awk '$3=="gene"' augustus_exonerate.sort.gff) -b $asm.liftoff.gene_pseudogene.gff | cut -f 9 | awk -F '[=|;]' '{print $2}' | sort -u > augustus_exonerate.sort.gff.noverlap.list
agat_sp_filter_feature_from_keep_list.pl --gff augustus_exonerate.sort.gff --keep_list augustus_exonerate.sort.gff.noverlap.list --output augustus_exonerate.sort.gff.noverlap.list.keep.gff
awk '{if ($3=="gene") print $0";gene_biotype=protein_coding"; else print $0}' augustus_exonerate.sort.gff.noverlap.list.keep.gff > augustus_exonerate.sort.gff.noverlap.list.keep.edit.gff
agat_sp_manage_IDs.pl -f augustus_exonerate.sort.gff.noverlap.list.keep.edit.gff --prefix augustus_exonerate --tair --type_dependent -o augustus_exonerate.sort.gff.noverlap.list.keep.edit.rename.gff

# Assign known gene names to augustus_exonerate gene set
gffread augustus_exonerate.sort.gff.noverlap.list.keep.edit.rename.gff -g $asm.fa -y augustus_exonerate.sort.gff.noverlap.list.keep.edit.rename.gff.pep.fa
blastp -query augustus_exonerate.sort.gff.noverlap.list.keep.edit.rename.gff.pep.fa \
    -out blastp.xml \
    -db GCF_000001405.40_GRCh38.p14_genomic.gff.pep.fa \
    -evalue 1e-5 -outfmt 5 -num_threads 8
python2 scripts/blast_xml_parse.py -i blastp.xml \
    -q GCF_000001405.40_GRCh38.p14_genomic.gff.pep.fa \
    -o blastp.xml.csv
cat blastp.xml.csv | awk '{print $1}' | grep 'augustus' | sort -Vu | awk '{print "grep -w "$1" blastp.xml.csv| head -n 1"}'| parallel -j 32 | cut -f 1,13 > blastp.xml.csv.best
python scripts/add_blast_functional_annotation.py augustus_exonerate.sort.gff.noverlap.list.keep.edit.rename.gff blastp.xml.csv.best GCF_000001405.40_GRCh38.p14_genomic.gff augustus_exonerate.sort.gff.noverlap.list.keep.edit.rename_add_blastp

# Finally, combine all
cat $asm.liftoff.gff \
augustus_exonerate.sort.gff.noverlap.list.keep.edit.rename_add_blastp.gff \
    | egrep -v '^#' \
    > $asm.liftoff_add_augustus_exonerate.gff

## (optional) keep the longest isoform
agat_sp_keep_longest_isoform.pl -gff $asm.liftoff_add_augustus_exonerate.gff -o $asm.tmp.gff
## standardize and sort gff
agat_convert_sp_gxf2gxf.pl -g $asm.tmp.gff -o $asm.gff


# (optional) functional annotation for final protein coding gff
grep 'gene_biotype=protein_coding' $asm.gff | cut -f 9 | awk -F '[=|;]' '{print $2}' > $asm.gff.protein_coding.id
agat_sp_filter_feature_from_keep_list.pl -f $asm.gff --kl $asm.gff.protein_coding.id -o $asm.protein_coding.gff
gffread $asm.protein_coding.gff -g $asm.fa -y $asm.protein_coding.cds.fasta
perl scripts/edit2aa.pl $asm.protein_coding.cds.fasta > interproscan.edit.fasta
interproscan.sh -appl Pfam -i interproscan.edit.fasta
agat_sp_manage_functional_annotation.pl -i interproscan.edit.fasta.tsv -o add_interpro -f $asm.protein_coding.gff
```

