import sys
import pysam
import pandas as pd


samples_list = pd.read_csv(sys.argv[1], sep='\t', header=None, names=['haplotype', 'consortium', 'population'], index_col=0)
consortiums = list(samples_list['consortium'].unique())
consortium_numbers = {i:0 for i in consortiums + ['others']}

f_out = open(f'{sys.argv[2]}.specific_sv_alleles.tsv', 'w')
with pysam.VariantFile(sys.argv[2], threads=32) as f:
    number = 0
    for rec in f.fetch():
        tmp_numbers = {i:0 for i in consortiums}
        consortium_alleles = {i:set() for i in consortiums}
        for sample, value_dict in rec.samples.items():
            if value_dict['GT'][0] != None and value_dict['GT'][0] != 0:
                tmp_numbers[samples_list.at[sample, 'consortium']] += 1
                consortium_alleles[samples_list.at[sample, 'consortium']].add(value_dict['GT'][0])
            
        flag = False
        if tmp_numbers[consortiums[0]] > 0 and not (tmp_numbers[consortiums[1]] == 0 and tmp_numbers[consortiums[2]] == 0):
            for i in range(1, len(rec.alts) + 1):
                if i in consortium_alleles[consortiums[0]] and i not in consortium_alleles[consortiums[1]] and i not in consortium_alleles[consortiums[2]]:
                    consortium_numbers[consortiums[0]] += 1
                    flag = True
                elif i in consortium_alleles[consortiums[1]] and i not in consortium_alleles[consortiums[0]] and i not in consortium_alleles[consortiums[2]]:
                    consortium_numbers[consortiums[1]] += 1
                elif i in consortium_alleles[consortiums[2]] and i not in consortium_alleles[consortiums[0]] and i not in consortium_alleles[consortiums[1]]:
                    consortium_numbers[consortiums[2]] += 1
                else:
                    consortium_numbers['others'] += 1
        if flag:
            number += 1
    print(consortium_numbers, file=f_out)
    print(f'Total SV records: {number}', file=f_out)
f_out.close()
