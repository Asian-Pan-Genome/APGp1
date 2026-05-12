import sys
import pysam
import pandas as pd


samples_list = pd.read_csv('id.list', sep='\t', header=None, names=['haplotype', 'source', 'population'], index_col=0)
sources = list(samples_list['source'].unique())
source_numbers = {i:0 for i in sources}

with pysam.VariantFile('APGp1-HPRCp1-HGSVCp3_MC_CN1v1.remove_telo_cent.final.SVs.vcf.gz') as f:
    number = 0
    for rec in f.fetch():
        tmp_numbers = {i:0 for i in sources}
        source_alleles = {i:set() for i in sources}
        for sample, value_dict in rec.samples.items():
            if value_dict['GT'][0] != None and value_dict['GT'][0] != 0:
                #sample_number.append(sample)
                if sample != 'CHM13v2':
                    tmp_numbers[samples_list.at[sample, 'source']] += 1
                    source_alleles[samples_list.at[sample, 'source']].add(value_dict['GT'][0])
        
    if tmp_numbers[sources[0]] > 0 and tmp_numbers[sources[1]] == 0 and tmp_numbers[sources[2]] == 0:
        source_numbers[sources[0]] += 1
    elif tmp_numbers[sources[1]] > 0 and tmp_numbers[sources[0]] == 0 and tmp_numbers[sources[2]] == 0:
        source_numbers[sources[1]] += 1
    elif tmp_numbers[sources[2]] > 0 and tmp_numbers[sources[0]] == 0 and tmp_numbers[sources[1]] == 0:
        source_numbers[sources[2]] += 1

with open(f'{sys.argv[-1]}.each.specific_sv.tsv', 'w') as f:
    f.write('\t'.join(map(str, list(source_numbers.keys()))) + '\n')
    f.write('\t'.join(map(str, list(source_numbers.values()))) + '\n')
