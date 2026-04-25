import sys
import pysam

if len(sys.argv) != 3:
    print(f'Usage: python {sys.argv[0]} input.vcf(.gz) out_prefix')
    print(f'Please `bcftools index input.vcf(.gz)` in advance')
    print('This script will output a tab-delimited bed-like file formatted as\nChrom\tPos\tEnd\tAllele\tAC\tAF\tReference\tSamples')
    sys.exit(1)

if sys.argv[1].endswith('.vcf'):
    f = pysam.VariantFile(sys.argv[1], 'r', threads=8)
elif sys.argv[1].endswith('.vcf.gz'):
    f = pysam.VariantFile(sys.argv[1], 'rb', threads=8)
    
f_out = open(f'{sys.argv[-1]}.vcf.bed', 'w')
f_out.write(f'Chrom\tPos\tEnd\tAllele\tAC\tAF\t{list(f.header.contigs)[0]}\t' + '\t'.join(list(f.header.samples)) + '\n')

sum_sample = len(f.header.samples) + 1
for rec in f.fetch():
    f_out.write(f'{rec.chrom}\t{rec.pos}\t{rec.pos - 1 + len(rec.ref)}\tREF\t{rec.info["AN"] + 1 - sum(rec.info["AC"])}\t{(rec.info["AN"] + 1 - sum(rec.info["AC"])) / sum_sample}\t1\t' + '\t'.join(["1" if value["GT"][0] == 0 else "0" for value in rec.samples.values()]) + '\n')

    for i, allele in enumerate(rec.alleles[1:]):
        f_out.write(f'{rec.chrom}\t{rec.pos}\t{rec.pos - 1 + len(rec.ref)}\tALT{i+1}\t{rec.info["AC"][i]}\t{rec.info["AC"][i] / sum_sample}\t0\t' + '\t'.join(["1" if value["GT"][0] == i+1 else "0" for value in rec.samples.values()]) + '\n')
    
    if rec.info["AN"] + 1 < sum_sample:
        f_out.write(f'{rec.chrom}\t{rec.pos}\t{rec.pos - 1 + len(rec.ref)}\tMissing\t{sum_sample - rec.info["AN"] - 1}\t{(sum_sample - rec.info["AN"] - 1) / sum_sample}\t0\t' + '\t'.join(["1" if value["GT"][0] == None else "0" for value in rec.samples.values()]) + '\n')

f.close()
f_out.close()
