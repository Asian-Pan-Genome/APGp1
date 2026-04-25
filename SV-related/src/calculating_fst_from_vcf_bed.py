import sys
import pandas as pd
import numpy as np
from scipy.special import comb


if len(sys.argv) != 4:
    print(f'Usage: python {sys.argv[0]} input.vcf.bed id.list output_prefix.tsv')
    print(f'The format of id.list: sample\tconsortium\tpopulation')
    print('By default, the output will be formatted as\nChrom\tPos\tEnd\tAllele_count\tAF_$populations\tPixy(APG, $population)\tDxy(APG, $population)\tFst(APG, $population)')
    print('where allele frequencies of each population are delimited by comma and the last one is for "Missing"')
    print('Be cautious! This script should be edited to tolerate missing genotypes or not')
    sys.exit(1)


vcf_bed = pd.read_csv(sys.argv[1], sep='\t', header=0)
samples_df = pd.read_csv(sys.argv[2], sep='\t', header=None, names=['haplotype', 'consortium', 'population'])
samples_df['population'] = samples_df.apply(lambda x: 'APG' if x['consortium'] == 'APG' else x['population'], axis=1)
populations = ['APG', 'EAS', 'EUR', 'AMR', 'AFR', 'SAS']
f_out = open(f'{sys.argv[-1]}.tsv', 'w')
f_out.write('\t'.join(['Chrom', 'Pos', 'End', 'Allele_count'] + \
                        populations+['Non_EAS'] + \
                        [f'Pixy(APG, {population})' for population in populations[1:]+['Non_EAS']] + \
                        [f'Dxy(APG, {population})' for population in populations[1:]+['Non_EAS']] + \
                        [f'Fst(APG, {population})' for population in populations[1:]+['Non_EAS']]) + \
            '\n')


for (chrom, pos, end), pre_out_df in vcf_bed.groupby(['Chrom', 'Pos', 'End']):
    #if 'Missing' not in list(pre_out_df['Allele']):
    population_af = {population:[] for population in populations+['Non_EAS']}
    for row_index, row in pre_out_df.iterrows():
        if row['Allele'] != 'Missing':
            for population in populations:
                population_af[population].append(row[samples_df.loc[samples_df['population'] == population, 'haplotype']].sum())
            population_af['Non_EAS'].append(row[samples_df.loc[(samples_df['population'] != 'APG') & (samples_df['population'] != 'EAS'), 'haplotype']].sum())
    
    Pixys = []
    Dxys = []
    Fsts = []
    for population in populations[1:]+['Non_EAS']:
        apg_af = []
        other_af = []
        for a, b in zip(population_af['APG'], population_af[population]):
            if a != 0 or b != 0:
                apg_af.append(a)
                other_af.append(b)
        
        if sum(apg_af) < 2:
            Pi1 = 0
        else:
            Pi1 = 1 - sum([comb(i, 2, exact=True) for i in apg_af]) / comb(sum(apg_af), 2, exact=True)
        if sum(other_af) < 2:
            Pi2 = 0
        else:
            Pi2 = 1 - sum([comb(i, 2, exact=True) for i in other_af]) / comb(sum(other_af), 2, exact=True)
        Pixy = (Pi1 + Pi2) / 2
        Pixys.append(round(Pixy, 4) if Pixy > 0 else 0.0)
    
        if sum(apg_af) == 0 and sum(other_af) == 0:
            Dxy = 0.0
        elif sum(apg_af) == 0 or sum(other_af) == 0:
            Dxy = 1
        else:
            apg_af = np.array(apg_af) / sum(apg_af)
            other_af = np.array(other_af) / sum(other_af)
            Dxy = 1 - sum(apg_af * other_af)
        Dxys.append(round(Dxy, 4) if Dxy > 0 else 0.0)
        if Dxy == 0:
            Fst = 0.0
        else:
            if Pixy / Dxy >= 1:
                Fst = 0.0
            else:
                Fst = round(1 - Pixy / Dxy, 4)
        Fsts.append(Fst)
        
        
    for population in populations+['Non_EAS']:
        if sum(population_af[population]) == 0:
            population_af[population] = np.zeros(len(population_af[population]))
        else:
            population_af[population] = np.round(np.array(population_af[population]) / sum(population_af[population]), 4)

    f_out.write(f'{chrom}\t{pos}\t{end}\t{len(population_af["APG"])}\t' + \
                '\t'.join([','.join(map(str, population_af[population])) for population in populations+['Non_EAS']]) + '\t' + \
                '\t'.join(map(str, Pixys)) + '\t' + \
                '\t'.join(map(str, Dxys)) + '\t' + \
                '\t'.join(map(str, Fsts)) + \
                '\n')
f_out.close()
