#!/usr/bin/bash
#SBATCH --job-name=C010contamblast
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=90
#SBATCH --mem=300g
#SBATCH --time=900:00:00

date

threads=90
dir="/slurm/users/wudongya/APG/reference/"

famID="C010-CHA-E10"

##MAKE_BLAST_DB
#makeblastdb -in /slurm/users/wudongya/APG/reference/contam_in_euks.fa -dbtype nucl -out /slurm/users/wudongya/APG/reference/contam_in_euks
#makeblastdb -in /slurm/users/wudongya/APG/reference/plastid.genomic.fasta -dbtype nucl -out /slurm/users/wudongya/APG/reference/plastid.genomic
#makeblastdb -in /slurm/users/wudongya/APG/reference/adaptors_for_screening_euks.fa -dbtype nucl -out /slurm/users/wudongya/APG/reference/adaptors_for_screening_euks

##BLAST_DATABASE
contam="/slurm/users/wudongya/APG/reference/contam_in_euks"
plastid="/slurm/users/wudongya/APG/reference/plastid.genomic"
mito="/slurm/users/wudongya/APG/reference/mito"
adap="/slurm/users/wudongya/APG/reference/adaptors_for_screening_euks"

for gender in {"Pat","Mat"}
do
prefix="${famID}_${gender}"
assembly="${famID}_${gender}_R4_R5_R3_R6.paf.fasta"
echo "$assembly!"
##euk_blast
echo "BLAST common contaminants!"
blastn -query $assembly -db $contam -task megablast  -num_threads ${threads} -word_size 28  -best_hit_overhang 0.1 -best_hit_score_edge 0.1 -dust yes -evalue 0.0001 -perc_identity 90 -outfmt 6 > ${prefix}.contam_in_euks.blast
cat ${prefix}.contam_in_euks.blast | awk '($3>=98.0 && $4>=50)||($3>=94.0 && $4>=100)||($3>=90.0 && $4>=200)' > ${prefix}.contam_in_euks.awk
##plastid_blast
echo "BLAST plastid!"
blastn -query $assembly -db $plastid -task megablast -num_threads ${threads} -word_size 28 -best_hit_overhang 0.1 -best_hit_score_edge 0.1 -dust yes -evalue 0.0001 -perc_identity 90 -outfmt 6 -soft_masking true > ${prefix}.plastid.blast
cat ${prefix}.plastid.blast | awk '$4>=500' > ${prefix}.plastid.awk
##mito_blast
echo "BLAST mito!"
blastn -query $assembly -db $mito -task megablast -num_threads ${threads} -word_size 28 -best_hit_overhang 0.1 -best_hit_score_edge 0.1 -dust yes -evalue 0.0001 -perc_identity 90 -outfmt 6 -soft_masking true > ${prefix}.mito.blast
cat ${prefix}.mito.blast | awk '$4>=500' > ${prefix}.mito.awk
##vector_blast
echo "BLAST adaptor sequences!"
blastn -query $assembly -db $adap -task megablast -num_threads ${threads} -word_size 28 -best_hit_overhang 0.1 -best_hit_score_edge 0.1 -dust yes -evalue 0.0001 -perc_identity 90 -outfmt 6 -soft_masking true > ${prefix}.adaptor.blast
done

date

