import sys
from Bio import SeqIO
import re

if len(sys.argv) != 5:
    print(f'Usage: python {sys.argv[0]} asm.fa sample.id hap.id version.id')
    sys.exit(1)


chr_ids = []
for record in SeqIO.parse(sys.argv[1], 'fasta'):
    if not re.search(fr'(?i)N+', str(record.seq)):
        chr_ids.append(record.id)

with open(f'{sys.argv[2]}_{sys.argv[3]}.{sys.argv[4]}.complete.chrs', 'w') as f:
    f.write('#Sample\tHaplotype\tchrs\tsum\n')
    if len(chr_ids) == 0:
        f.write(f'{sys.argv[2]}\t{sys.argv[3]}\t\t0\n')
    else:
        f.write(f'{sys.argv[2]}\t{sys.argv[3]}\t{chr_ids[0]}\t{len(chr_ids)}\n')
    if len(chr_ids) >= 2:
        for chr in chr_ids[1:]:
            f.write(f'\t\t{chr}\t\n')
