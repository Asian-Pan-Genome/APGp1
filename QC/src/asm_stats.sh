if [[ "$#" != 5 ]]; then
    echo "Usage: bash asm_stats.sh <sample> <haplotype> <version> <asm.fa> <threads>"
    echo -e "\t\t\t <sample>\t: sample id"
    echo -e "\t\t\t <haplotype>\t: mat or pat / hap1 or hap2 ..."
    echo -e "\t\t\t <version>\t: version id (v0.9 ...)"
    echo -e "\t\t\t <asm.fa>\t: Assembly fasta file"
    echo -e "\t\t\t <threads>\t: Number of threads"
    echo -e "\nThis script is used for computing assembly size,"
    echo -e "\t\t\t\t  N50,"
    echo -e "\t\t\t\t  auN,"
    echo -e "\t\t\t\t  complete chromosomes,"
    echo -e "\t\t\t\t  compleasm, and asmgene"   
    exit 1
fi

set -eo pipefail

sample=$1
hap=$2
version=$3
asm=$4
threads=$5


# assembly size, N50, auN --> ${sample}_${hap}.${version}.stats
python src/calculate_continuity_metrics.py $asm > ${sample}_${hap}.${version}.stats

asm_size=`grep "Assembly size" ${sample}_${hap}.${version}.stats | cut -f 2`
scaf_n50=`grep "N50" ${sample}_${hap}.${version}.stats | cut -f 2`
ctg_n50=`grep "N50" ${sample}_${hap}.${version}.stats | cut -f 3`
scaf_aun=`grep "auN" ${sample}_${hap}.${version}.stats | cut -f 2`
ctg_aun=`grep "auN" ${sample}_${hap}.${version}.stats | cut -f 3`

echo -e "#Sample\tHaplotype\tAssembly size\tScaffold N50\tContig N50\tScaffold auN\tContig auN" > ${sample}_${hap}.${version}.stats
echo -e "${sample}\t${hap}\t${asm_size}\t${scaf_n50}\t${ctg_n50}\t${scaf_aun}\t${ctg_aun}" >> ${sample}_${hap}.${version}.stats
echo ${sample}_${hap}.${version}.stats done!


# complete chromosomes --> ${sample}_${hap}.complete.chrs
python src/QC_calculate_complete_chrs.py $asm ${sample} ${hap} ${version}
echo ${sample}_${hap}.${version}.complete.chrs done!


# compleasm --> ${sample}_${hap}.${version}.compleasm
compleasm run -a $asm -o compleasm_${hap}.${version} -t $threads -l primates \
              -L src/compleasm_lineages_library/mb_downloads/

S_p=`grep "S:" compleasm_${hap}.${version}/summary.txt | cut -d '%' -f 1 | cut -d ':' -f 2`
S_n=`grep "S:" compleasm_${hap}.${version}/summary.txt | cut -d ' ' -f 2`
D_p=`grep "D:" compleasm_${hap}.${version}/summary.txt | cut -d '%' -f 1 | cut -d ':' -f 2`
D_n=`grep "D:" compleasm_${hap}.${version}/summary.txt | cut -d ' ' -f 2`
F_p=`grep "F:" compleasm_${hap}.${version}/summary.txt | cut -d '%' -f 1 | cut -d ':' -f 2`
F_n=`grep "F:" compleasm_${hap}.${version}/summary.txt | cut -d ' ' -f 2`
I_p=`grep "I:" compleasm_${hap}.${version}/summary.txt | cut -d '%' -f 1 | cut -d ':' -f 2`
I_n=`grep "I:" compleasm_${hap}.${version}/summary.txt | cut -d ' ' -f 2`
M_p=`grep "M:" compleasm_${hap}.${version}/summary.txt | cut -d '%' -f 1 | cut -d ':' -f 2`
M_n=`grep "M:" compleasm_${hap}.${version}/summary.txt | cut -d ' ' -f 2`
N_n=`grep "N:" compleasm_${hap}.${version}/summary.txt | cut -d ':' -f 2`

echo -e "#Sample\tHaplotype\tSingle Copy Complete Genes (%)\tSingle Copy Complete Genes (#)\tDuplicated Complete Genes (%)\tDuplicated Complete Genes (#)\tFragmented Genes, subclass 1 (%)\tFragmented Genes, subclass 1 (#)\tFragmented Genes, subclass 2 (%)\tFragmented Genes, subclass 2 (#)\tMissing Genes (%)\tMissing Genes (#)\tSum (#)" > ${sample}_${hap}.${version}.compleasm
echo -e "${sample}\t${hap}\t${S_p}\t${S_n}\t${D_p}\t${D_n}\t${F_p}\t${F_n}\t${I_p}\t${I_n}\t${M_p}\t${M_n}\t${N_n}" >> ${sample}_${hap}.${version}.compleasm
rm -rf compleasm_${hap}.${version}/primates_odb10
echo ${sample}_${hap}.${version}.compleasm done!


# asmgene --> ${sample}_${hap}.${version}.asmgene
## ${sample}_${hap}.${version}.chm13.asmgene
cdna=src/Homo_sapiens.GRCh38.cdna.all.fa.gz
minimap2 -cxsplice:hq -t $threads $asm $cdna > ${sample}_${hap}.${version}.cdna.paf


paftools.js asmgene -a src/CHM13v2.cdna.paf ${sample}_${hap}.${version}.cdna.paf > ${sample}_${hap}.${version}.chm13.asmgene

full_sgl_ref=`grep "full_sgl" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 3`
full_sgl_asm=`grep "full_sgl" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 4`
full_dup_ref=`grep "full_dup" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 3`
full_dup_asm=`grep "full_dup" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 4`
frag_ref=`grep "frag" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 3`
frag_asm=`grep "frag" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 4`
part50_ref=`grep "part50+" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 3`
part50_asm=`grep "part50+" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 4`
part10pl_ref=`grep "part10+" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 3`
part10pl_asm=`grep "part10+" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 4`
part10mi_ref=`grep "part10-" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 3`
part10mi_asm=`grep "part10-" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 4`
dup_cnt_ref=`grep "dup_cnt" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 3`
dup_cnt_asm=`grep "dup_cnt" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 4`
dup_sum_ref=`grep "dup_sum" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 3`
dup_sum_asm=`grep "dup_sum" ${sample}_${hap}.${version}.chm13.asmgene | cut -f 4`

echo -e "#Sample\tHaplotype\tfull_sgl in ref\tfull_sgl in asm\tfull_dup in ref\tfull_dup in asm\tfrag in ref\tfrag in asm\tpart50+ in ref\tpart50+ in asm\tpart10+ in ref\tpart10+ in asm\tpart10- in ref\tpart10- in asm\tdup_cnt in ref\tdup_cnt in asm\tdup_sum in ref\tdup_sum in asm" > ${sample}_${hap}.${version}.chm13.asmgene
echo -e "${sample}\t${hap}\t${full_sgl_ref}\t${full_sgl_asm}\t${full_dup_ref}\t${full_dup_asm}\t${frag_ref}\t${frag_asm}\t${part50_ref}\t${part50_asm}\t${part10pl_ref}\t${part10pl_asm}\t${part10mi_ref}\t${part10mi_asm}\t${dup_cnt_ref}\t${dup_cnt_asm}\t${dup_sum_ref}\t${dup_sum_asm}" >> ${sample}_${hap}.${version}.chm13.asmgene
echo ${sample}_${hap}.${version}.chm13.asmgene done!
