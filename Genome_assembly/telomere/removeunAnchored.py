#!/usr/bin/env python3

import sys

def read_fasta(fp):
    name, seq = None, []
    for line in fp:
        line = line.rstrip()
        if line.startswith(">"):
            if name:
                yield (name, ''.join(seq))
            name, seq = line, []
        else:
            seq.append(line)
    if name:
        yield (name, ''.join(seq))


def rname(chrom):
    return chrom.split("_")[0]

if len(sys.argv) < 2:
    sys.exit(f"python3 {sys.argv[0]}  *.fasta outpre")

outpre = sys.argv[2]
fa = open(outpre + ".chr.fasta", 'w')
mt = open(outpre + ".mitogenome.fa", 'w')
useless = open(outpre + ".unAnchored.fa", 'w')
chrmap = open(outpre + ".chrID.map", 'w')

chromosome = {}
def sortbynum(e):
    if e == 'M':
        return 25
    elif e == 'X':
        return 23
    elif e == 'Y':
        return 24
    else:
        return int(e)

with open(sys.argv[1], 'r') as fh:
    for i in read_fasta(fh):
        name, seq = i
        name = name.split()[0]
        name = name.replace(">", "")
        # chrM
        if name.startswith("NC_012920.1"):
            print(f"{name}\tchrM", file=chrmap)
            print(f">chrM\n{seq}", file=mt)
        elif name.startswith("chr") and 'TeloTrim' not in name:
            new_name = rname(name)
            print(f"{name}\t{new_name}", file=chrmap)
            #print(f">{new_name}\n{seq}", file=fa)
            order = new_name.replace("chr", "")
            chromosome[order] = seq
        else:
            print(f">{name}\n{seq}", file=useless)

for i in sorted(chromosome, key=sortbynum):
    print(f">chr{i}\n{chromosome[i]}", file=fa)

fa.close()
mt.close()
useless.close()
chrmap.close()


