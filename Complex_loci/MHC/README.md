# MHC locus
The MHC region represents one of the most intensively studied human genomic regions, with over seven decades of research driven by its critical role in immunity and disease. We deciphered the MHC based on manually curated gene annotations and graph decomposition.

## Gene annotation
### Requirments
- Immuannot
- Liftoff
- AGAT
- gffutils

### Run
- First, prepare a list formatted as `hap\tfasta`.
- Next, install [Immuannot](https://github.com/YingZhou001/Immuannot) and follow its instructions to prepare the IPD-IMGT/HLA reference database.
- Subsequently, prepare the reference sequence and gene annotation. You could use ours in the `src` folder, which contains additional HLA genes on the alternative scaffolds (see details in our paper). The file `type.list` is needed for `Liftoff`.

```shell
bash gene_annotation.sh ${immuannot_bin} ${IPD_dir} $threads src/GRCh38.MHC.fa src/GRCh38.MHC.fa.gff src/type.list
```
This pipeline merged the annotations from Immuannot and Liftoff, resulting in a relatively comprehensive MHC gene set.


## Graph decomposition
MC graph was used for identifying the complex loci in the MHC region, where SVs larger than 5 Kbp, present in at least five assemblies, were filtered by `bcftools`.For each candidate locus, graph substructures were extracted using `odgi` and visualized with `Bandage`. Gene orientation and paths, representing diverse structural haplotypes, were manually annotated and drawn.

### HLA class I
<img width="1651" height="654" alt="image" src="https://github.com/user-attachments/assets/196b9c37-c31b-42bc-812a-812037d0fc1a" />

#### Structural haplotypes
<img width="1646" height="768" alt="image" src="https://github.com/user-attachments/assets/78704223-7d40-46c9-834f-eae5bb2e712e" />


### MICA/B
<img width="559" height="827" alt="image" src="https://github.com/user-attachments/assets/a64e7cfd-da8c-434c-9445-b2ddee75b484" />

#### Structural haplotypes
<img width="870" height="607" alt="image" src="https://github.com/user-attachments/assets/bfbcd367-5927-477e-aa36-7398ae917818" />

