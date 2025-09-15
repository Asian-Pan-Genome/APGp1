import sys
import gffutils


if len(sys.argv) != 6:
    print(f'Usage: python {sys.argv[0]} gff3_file1 gff3_file2 overlap_fraction final_source outgff_prefix')
    print('Be cautious!!! This script uses the first gff file as the backbone and can\'t remove redundant queries')
    print('so you\'d better provide the more reliable one as the first input (like augustus.gff in the original usage)')
    sys.exit(1)


db1 = gffutils.create_db(sys.argv[1], ':memory:', force=True, verbose=True, merge_strategy='create_unique', keep_order=True)
db2 = gffutils.create_db(sys.argv[2], ':memory:', force=True, verbose=True, merge_strategy='create_unique', keep_order=True)
overlap_fraction = float(sys.argv[3])
final_source = sys.argv[4]
f_out = open(f'{sys.argv[-1]}.gff', 'w')
db1_featuretyps = db1.featuretypes()
for i in db1_featuretyps:
    if i == 'cds' or i == 'CDS':
        db1_cds = i
        break
db2_featuretyps = db2.featuretypes()
for i in db2_featuretyps:
    if i == 'cds' or i == 'CDS':
        db2_cds = i
        break


db1_genes = db1.features_of_type(featuretype='gene', order_by=('seqid', 'start'))
for db1_gene in db1_genes:
    db1_gene_attributes = [f'{tag}={value[0]}' for tag, value in db1_gene.attributes.items()]
    db1_gene_mRNA = list(db1.children(db1_gene, featuretype='mRNA', order_by='start'))[0]
    db1_gene_mRNA_attributes = [f'{tag}={value[0]}' for tag, value in db1_gene_mRNA.attributes.items()]
    db1_gene_exons = db1.children(db1_gene, featuretype='exon', order_by='start')
    
    db2_genes = db2.region(seqid=db1_gene.seqid, start=db1_gene.start, end=db1_gene.end, strand=db1_gene.strand, featuretype='gene')
    for db2_gene in db2_genes:
        overlap_gene = min(db1_gene.end, db2_gene.end) - max(db1_gene.start, db2_gene.start) + 1
        if overlap_gene / (db1_gene.end - db1_gene.start + 1) >= overlap_fraction and overlap_gene / (db2_gene.end - db2_gene.start + 1) >= overlap_fraction:
            exon_write = False
            
            exon_count = 0
            for db1_gene_exon in db1_gene_exons:
                db1_gene_exon_attributes = [f'{tag}={value[0]}' for tag, value in db1_gene_exon.attributes.items()]
                db1_gene_cdss = db1.children(db1_gene, limit=(db1_gene_exon.seqid, db1_gene_exon.start-1, db1_gene_exon.end+1), featuretype=db1_cds, order_by='start', completely_within=True)
                
                db2_gene_exons = db2.children(db2_gene, limit=(db1_gene_exon.seqid, db1_gene_exon.start, db1_gene_exon.end), featuretype='exon', order_by='start')
                for db2_gene_exon in db2_gene_exons:
                    overlap_exon = min(db1_gene_exon.end, db2_gene_exon.end) - max(db1_gene_exon.start, db2_gene_exon.start) + 1
                    if overlap_exon / (db1_gene_exon.end - db1_gene_exon.start + 1) >= overlap_fraction and overlap_exon / (db2_gene_exon.end - db2_gene_exon.start + 1) >= overlap_fraction:
                        cds_write = False
                        
                        cds_count = 0
                        for db1_gene_cds in db1_gene_cdss:
                            db1_gene_cds_attributes = [f'{tag}={value[0]}' for tag, value in db1_gene_cds.attributes.items()]

                            db2_gene_cdss = db2.children(db2_gene, limit=(db1_gene_cds.seqid, db1_gene_cds.start, db1_gene_cds.end), featuretype=db2_cds, order_by='start')
                            for db2_gene_cds in db2_gene_cdss:
                                overlap_cds = min(db1_gene_cds.end, db2_gene_cds.end) - max(db1_gene_cds.start, db2_gene_cds.start) + 1
                                if overlap_cds / (db1_gene_cds.end - db1_gene_cds.start + 1) >= overlap_fraction and overlap_cds / (db2_gene_cds.end - db2_gene_cds.start + 1) >= overlap_fraction:
                                    if cds_count == 0:
                                        pre_cds_start = max(db1_gene_cds.start, db2_gene_cds.start)
                                        pre_cds_end = min(db1_gene_cds.end, db2_gene_cds.end)
                                        cds_count = 1
                                    f_out.write(f'{db1_gene_cds.seqid}\t{final_source}\tCDS\t{max(db1_gene_cds.start, db2_gene_cds.start)}\t{min(db1_gene_cds.end, db2_gene_cds.end)}\t.\t{db1_gene_cds.strand}\t.\t' + ';'.join(db1_gene_cds_attributes) + '\n')
                                    cds_write = True
                                    pre_cds_start = min(pre_cds_start, max(db1_gene_cds.start, db2_gene_cds.start))
                                    pre_cds_end = max(pre_cds_end, min(db1_gene_cds.end, db2_gene_cds.end))
                                    break
                        
                        if cds_write == True:
                            if exon_count == 0:
                                pre_exon_start = pre_cds_start
                                pre_exon_end = pre_cds_end
                                exon_count = 1
                            f_out.write(f'{db1_gene_exon.seqid}\t{final_source}\texon\t{pre_cds_start}\t{pre_cds_end}\t.\t{db1_gene_exon.strand}\t.\t' + ';'.join(db1_gene_exon_attributes) + '\n')
                            exon_write = True
                            pre_exon_start = min(pre_exon_start, pre_cds_start)
                            pre_exon_end = max(pre_exon_start, pre_cds_end)
                            break
            if exon_write == True:
                f_out.write(f'{db1_gene_mRNA.seqid}\t{final_source}\tmRNA\t{pre_exon_start}\t{pre_exon_end}\t.\t{db1_gene.strand}\t.\t' + ';'.join(db1_gene_mRNA_attributes) + '\n')
                f_out.write(f'{db1_gene.seqid}\t{final_source}\tgene\t{pre_exon_start}\t{pre_exon_end}\t.\t{db1_gene.strand}\t.\t' + ';'.join(db1_gene_attributes) + '\n')
                break
f_out.close()
