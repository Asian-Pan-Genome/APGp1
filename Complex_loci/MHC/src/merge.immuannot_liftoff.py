import sys
import gffutils
import re


if len(sys.argv) != 5:
    print(f'Usage: python {sys.argv[0]} Immuannot.gtf.gz HLA.immuannot.list liftoff.gff_polished outprefix_gff')
    sys.exit(1)

db_immua = gffutils.create_db(sys.argv[1], ':memory:', force=True, verbose=True, merge_strategy='create_unique', keep_order=True, disable_infer_genes=True, disable_infer_transcripts=True)
db_liftoff = gffutils.create_db(sys.argv[3], ':memory:', force=True, verbose=True, merge_strategy='create_unique', keep_order=True)

hla_immua = {}
with open(sys.argv[2], 'r') as f:
    for line in f:
        name, bio_type = line.strip().split('\t')
        hla_immua[name] = bio_type

f_out = open(f'{sys.argv[-1]}.gff', 'w')

hla_immua_genes = []
# Attributes are stored in the attributes dictionary. Values are always in a list, even if there’s only one item
for i in db_immua.features_of_type('gene', order_by=('seqid', 'start')):
    if i.attributes['gene_name'][0] in hla_immua:
        hla_immua_genes.append((i.start, i.end))
        
        if 'consensus' in list(db_immua.children(i, featuretype='transcript', order_by='start'))[0].attributes:
            consensus = list(db_immua.children(i, featuretype='transcript', order_by='start'))[0].attributes['consensus'][0]
            gff_out_attributes = f"ID={i.attributes['gene_id'][0]};consensus={consensus};Name={i.attributes['gene_name'][0]};gene_biotype={hla_immua[i.attributes['gene_name'][0]]}"
        else:
            gff_out_attributes = f"ID={i.attributes['gene_id'][0]};Name={i.attributes['gene_name'][0]};gene_biotype={hla_immua[i.attributes['gene_name'][0]]}"
        
        if 'pseudogene' in hla_immua[i.attributes['gene_name'][0]]:
            f_out.write(f'{i.seqid}\tImmuannot\tpseudogene\t{i.start}\t{i.end}\t{i.score}\t{i.strand}\t{i.frame}\t{gff_out_attributes}\n')
            j_fea_type = 'transcript'
        else:
            f_out.write(f'{i.seqid}\tImmuannot\tgene\t{i.start}\t{i.end}\t{i.score}\t{i.strand}\t{i.frame}\t{gff_out_attributes}\n')
            j_fea_type = 'mRNA'
        
        for j in db_immua.children(i, featuretype='transcript', order_by='start'):
            gff_out_attributes = f"ID={j.attributes['transcript_id'][0]};Parent={i.attributes['gene_id'][0]}"
            f_out.write(f'{j.seqid}\tImmuannot\t{j_fea_type}\t{j.start}\t{j.end}\t{j.score}\t{j.strand}\t{j.frame}\t{gff_out_attributes}\n')
            
            #for fea_type in ['UTR', 'exon', 'start_codon', 'CDS', 'stop_codon']:
            for fea_type in ['exon', 'CDS']:
                for k in db_immua.children(i, featuretype=fea_type, order_by='start'):
                    gff_out_attributes = f"ID={k.id}-{j.attributes['transcript_id'][0]};Parent={j.attributes['transcript_id'][0]}"
                    f_out.write(f'{k.seqid}\tImmuannot\t{k.featuretype}\t{k.start}\t{k.end}\t{k.score}\t{k.strand}\t{k.frame}\t{gff_out_attributes}\n')


#hla_liftoff_genes = {}
hla_liftoff_genes = []
for i in db_liftoff.features_of_type(('gene', 'pseudogene'), order_by=('seqid', 'start')):
    if i.attributes['Name'][0] == 'C4A' or i.attributes['Name'][0] == 'C4B':
        continue
    if i.attributes['Name'][0] not in hla_immua:
        if i.attributes['Name'][0].startswith('HLA-'):
            flag = 0
            for (start, end) in hla_immua_genes:
                if start < i.end and end > i.start:
                    flag = 1
                    break
            if flag == 0:
                #if i.attributes['Name'][0] not in hla_liftoff_genes:
                #    hla_liftoff_genes[i.attributes['Name'][0]] = []
                #hla_liftoff_genes[i.attributes['Name'][0]].append((i.id, i.start, i.end, i.end - i.start + 1))
                hla_liftoff_genes.append((i.id, i.start, i.end, i.end - i.start + 1))
            continue
        else:
            gff_attributes = ";".join([f"{key}={','.join(value)}" for key, value in i.attributes.items()])
            f_out.write(f'{i.seqid}\t{i.source}\t{i.featuretype}\t{i.start}\t{i.end}\t{i.score}\t{i.strand}\t{i.frame}\t{gff_attributes}\n')
            for j in db_liftoff.children(i, order_by='start'):
                gff_attributes = ";".join([f"{key}={','.join(value)}" for key, value in j.attributes.items()])
                f_out.write(f'{j.seqid}\t{j.source}\t{j.featuretype}\t{j.start}\t{j.end}\t{j.score}\t{j.strand}\t{j.frame}\t{gff_attributes}\n')

hla_liftoff_genes = sorted(hla_liftoff_genes, key=lambda x:x[-1], reverse=True)
new_hla_liftoff_genes = [hla_liftoff_genes[0],]
if len(hla_liftoff_genes) > 1:
    for (gene_id, start, end, length) in hla_liftoff_genes[1:][::-1]:
        flag = 0
        for (gene_id2, start2, end2, length2) in new_hla_liftoff_genes:
            if start2 < end and end2 > start:
                if length2 >= length:
                    flag = 1
                    continue
                else:
                    del new_hla_liftoff_genes[new_hla_liftoff_genes.index((gene_id2, start2, end2, length2))]
        if flag == 0:
            new_hla_liftoff_genes.append((gene_id, start, end, length))
for (gene_id, start, end, length) in new_hla_liftoff_genes:
    i = db_liftoff[gene_id]
    gff_attributes = ";".join([f"{key}={','.join(value)}" for key, value in i.attributes.items()])
    f_out.write(f'{i.seqid}\t{i.source}\t{i.featuretype}\t{i.start}\t{i.end}\t{i.score}\t{i.strand}\t{i.frame}\t{gff_attributes}\n')
    for j in db_liftoff.children(i, order_by='start'):
        gff_attributes = ";".join([f"{key}={','.join(value)}" for key, value in j.attributes.items()])
        f_out.write(f'{j.seqid}\t{j.source}\t{j.featuretype}\t{j.start}\t{j.end}\t{j.score}\t{j.strand}\t{j.frame}\t{gff_attributes}\n')


#genes = list(hla_liftoff_genes.keys())
#for gene in genes:
#    gene_list = hla_liftoff_genes[gene]


# for gene in hla_liftoff_genes.keys():
#     if len(hla_liftoff_genes[gene]) > 1:
#         gene_list = sorted(hla_liftoff_genes[gene], key=lambda x:x[-1], reverse=True)
#         gene_id, start, end = gene_list[0][:-1]
#         new_gene_list = [(gene_id, start, end), ]
#         for (gene_id2, start2, end2, _) in gene_list[1:]:
#             if start2 < end and end2 > start:
#                 continue
#             else:
#                 new_gene_list.append((gene_id2, start2, end2))
#         hla_liftoff_genes[gene] = new_gene_list

# for gene in hla_liftoff_genes.keys():


# for gene in hla_liftoff_genes.keys():
#     if len(hla_liftoff_genes[gene]) == 1:
#         i = db_liftoff[hla_liftoff_genes[gene][0][0]]
#         gff_attributes = ";".join([f"{key}={','.join(value)}" for key, value in i.attributes.items()])
#         f_out.write(f'{i.seqid}\t{i.source}\t{i.featuretype}\t{i.start}\t{i.end}\t{i.score}\t{i.strand}\t{i.frame}\t{gff_attributes}\n')
#         for j in db_liftoff.children(i, order_by='start'):
#             gff_attributes = ";".join([f"{key}={','.join(value)}" for key, value in j.attributes.items()])
#             f_out.write(f'{j.seqid}\t{j.source}\t{j.featuretype}\t{j.start}\t{j.end}\t{j.score}\t{j.strand}\t{j.frame}\t{gff_attributes}\n')
#     else:
#         gene_list = sorted(hla_liftoff_genes[gene], key=lambda x:x[-1], reverse=True)
#         gene_id, start, end = gene_list[0][:-1]
#         new_gene_list = [gene_id,]
#         for (gene_id2, start2, end2, _) in gene_list[1:]:
#             if start2 < end and end2 > start:
#                 continue
#             else:
#                 new_gene_list.append(gene_id2)
        
#         for gene_id in new_gene_list:
#             i = db_liftoff[gene_id]
#             gff_attributes = ";".join([f"{key}={','.join(value)}" for key, value in i.attributes.items()])
#             f_out.write(f'{i.seqid}\t{i.source}\t{i.featuretype}\t{i.start}\t{i.end}\t{i.score}\t{i.strand}\t{i.frame}\t{gff_attributes}\n')
#             for j in db_liftoff.children(i, order_by='start'):
#                 gff_attributes = ";".join([f"{key}={','.join(value)}" for key, value in j.attributes.items()])
#                 f_out.write(f'{j.seqid}\t{j.source}\t{j.featuretype}\t{j.start}\t{j.end}\t{j.score}\t{j.strand}\t{j.frame}\t{gff_attributes}\n')
f_out.close()
