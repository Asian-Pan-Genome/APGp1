import sys
import pysam
import pandas as pd


samples_list = pd.read_csv(sys.argv[1], sep='\t', header=None, names=['haplotype', 'consortium', 'population'], index_col=0)
consortiums = list(samples_list['consortium'].unique())
consortium_numbers = {i:0 for i in consortiums + [(consortiums[j], consortiums[k]) for j in range(len(consortiums)) for k in range(len(consortiums)) if k > j] + [(consortiums[0], consortiums[1], consortiums[2])]}

with pysam.VariantFile(sys.argv[2]) as f:
    number = 0
    for rec in f.fetch():
        tmp_numbers = {i:0 for i in consortiums}
        consortium_alleles = {i:set() for i in consortiums}
        for sample, value_dict in rec.samples.items():
            if value_dict['GT'][0] != None and value_dict['GT'][0] != 0:
                tmp_numbers[samples_list.at[sample, 'consortium']] += 1
                consortium_alleles[samples_list.at[sample, 'consortium']].add(value_dict['GT'][0])

        if tmp_numbers[consortiums[0]] > 0 and tmp_numbers[consortiums[1]] == 0 and tmp_numbers[consortiums[2]] == 0:
            consortium_numbers[consortiums[0]] += 1
        elif tmp_numbers[consortiums[1]] > 0 and tmp_numbers[consortiums[0]] == 0 and tmp_numbers[consortiums[2]] == 0:
            consortium_numbers[consortiums[1]] += 1
        elif tmp_numbers[consortiums[2]] > 0 and tmp_numbers[consortiums[0]] == 0 and tmp_numbers[consortiums[1]] == 0:
            consortium_numbers[consortiums[2]] += 1
    
        elif tmp_numbers[consortiums[0]] > 0 and tmp_numbers[consortiums[1]] > 0 and tmp_numbers[consortiums[2]] == 0:
            consortium_numbers[(consortiums[0], consortiums[1])] += 1
        elif tmp_numbers[consortiums[0]] > 0 and tmp_numbers[consortiums[2]] > 0 and tmp_numbers[consortiums[1]] == 0:
            consortium_numbers[(consortiums[0], consortiums[2])] += 1
        elif tmp_numbers[consortiums[1]] > 0 and tmp_numbers[consortiums[2]] > 0 and tmp_numbers[consortiums[0]] == 0:
            consortium_numbers[(consortiums[1], consortiums[2])] += 1
    
        elif tmp_numbers[consortiums[0]] > 0 and tmp_numbers[consortiums[1]] > 0 and tmp_numbers[consortiums[2]] > 0:
            consortium_numbers[(consortiums[0], consortiums[1], consortiums[2])] += 1


with open(f'{sys.argv[2]}.specific_sv_records.tsv', 'w') as f:
    f.write('\t'.join(map(str, list(consortium_numbers.keys()))) + '\n')
    f.write('\t'.join(map(str, list(consortium_numbers.values()))) + '\n')

    