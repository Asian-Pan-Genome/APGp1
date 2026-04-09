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

def read_miss(f):
    missed = {}
    with open(f, 'r') as fh:
        for i in fh:
            chrom, end = i.strip().split()
            if missed.get(chrom):
                missed[chrom].update({end: 1})
            else:
                missed.update({chrom: {end: 1}})
    return missed


def rname(chrom):
    return chrom.split("_")[0]

if len(sys.argv) < 3:
    sys.exit(f"python3 {sys.argv[0]} *.teloMiss.txt *.fasta")

missed = read_miss(sys.argv[1])
outpre = sys.argv[3]
default_ext_copy = 1000
telomere_pattern = "TTAGGG"
fa = open(outpre + ".teloRefine.fasta", 'w')
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

with open(sys.argv[2], 'r') as fh:
    for i in read_fasta(fh):
        name, seq = i
        name = name.split()[0]
        name = name.replace(">", "")
        # chrM
        if name.startswith("NC_012920.1"):
            #print(f">chrM\n{seq}", file=fa)
            chromosome['M'] = seq
            print(f"{name}\tchrM", file=chrmap)
        elif 'TeloTrim' in name:  # missassembly trimed in last step
            print(f">{name}\n{seq}", file=useless)
        # only deal with chromosome
        elif name.startswith("chr"):
            if missed.get(name):
                if missed[name].get('head'):
                    seq = telomere_pattern * default_ext_copy + seq

                if missed[name].get('tail'):
                    seq = seq + telomere_pattern * default_ext_copy
                new_name = rname(name)
                print(f"{name}\t{new_name}", file=chrmap)
                #print(f">{new_name}\n{seq}", file=fa)
                order = new_name.replace("chr", "")
                chromosome[order] = seq
            else:
                # no missing, just rename
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
useless.close()
chrmap.close()


