immuannot_bin=$1
IPD_dir=$2
threads=$3
reference_fasta=$4
reference_gff=$5
type_list=$6

cat id.list | while read -r -a line; do
    sample=${line[0]}
    fasta=${line[1]}
    
    bash ${immuannot_bin} -r ${IPD_dir} -c $fasta -o $sample -t $threads
    liftoff $fasta ${reference_fasta} -sc 0.95 -copies -g ${reference_gff} -polish -o $sample.MHC.liftoff.gff -exclude_partial -p $threads -f ${type_list}

    rm -rf $sample.MHC.liftoff.gff_polished.rename.gff
    agat_sq_manage_IDs.pl --gff $sample.MHC.liftoff.gff_polished -o $sample.MHC.liftoff.gff_polished.rename.gff
    python src/merge.immuannot_liftoff.py $sample.gtf.gz src/HLA.immuannot.list $sample.MHC.liftoff.gff_polished.rename.gff $sample.merge.immuannot_liftoff
    rm -rf $sample.final.gff
    agat_convert_sp_gxf2gxf.pl -g $sample.merge.immuannot_liftoff.gff -o $sample.final.gff
done
