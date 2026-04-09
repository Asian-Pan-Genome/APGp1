#!/usr/bin/env python3
import sys
from icecream import ic

if len(sys.argv) < 3:
    sys.exit(f"python3 {sys.argv[0]} genome.fa.fai *.gap *.telo.bed")

def save2Ddict(thedict, ka, kb, val):
    if ka not in thedict:
        thedict.update({ka:{kb:val}})
    else:
        thedict[ka].update({kb: val})
    return thedict

# https://www.notion.so/how-to-trim-wrong-telomere-3849f7f82ef74ab99a9b73cbd57f69e9?pvs=4
distance_cutoff = 3000

def main():
    items = {}
    gsize = {}
    contain_gaps_chr = set()
    # read fai
    with open(sys.argv[1], 'r') as fh:
        for i in fh:
            tmp = i.strip().split()
            chrid, length = tmp[0], int(tmp[1])
            gsize[chrid] = length
    # read gap from gap.bed
    with open(sys.argv[2], 'r') as fh:
        for i in fh:
            tmp = i.strip().split()
            chrid, start, end = tmp[0], int(tmp[1]), int(tmp[2])
            contain_gaps_chr.add(chrid)
            if chrid in items:
                items[chrid].append([start, end, 'gap'])
            else:
                items[chrid] = [[start, end, 'gap'],]
    # read telo
    with open(sys.argv[3], 'r') as fh:
        for i in fh:
            tmp = i.strip().split()
            chrid, start, end = tmp[0], int(tmp[1]), int(tmp[2])
            if chrid in items:
                items[chrid].append([start, end, 'telo'])
            else:
                items[chrid] = [[start, end, 'telo'],]
    #out = open("teloTrim.edit.bed", 'w')
    for chrom in contain_gaps_chr:
        if len(items[chrom]) < 2:
            continue
        else:
            sorted_items = sorted(items[chrom])
            i = 0
            while i < len(sorted_items) - 1:
                regionA = sorted_items[i]
                regionB = sorted_items[i + 1]
                startA, endA, typeA = regionA
                startB, endB, typeB = regionB
                """TEST
                if typeA == 'gap' and typeB == 'telo' and startA < 500000:
                    #ic(typeA, typeB)
                    #print(f"head distance: {startB - endA}")
                elif typeA == 'telo' and typeB == 'gap' and gsize[chrom] - endA < 500000:
                    #ic(typeA, typeB)
                    #print(f"end distance: {startB - endA}")
                """
                # [----GAP-TELO----------------------------------------
                #  >>>>>-----------------------------------------------
                if typeA == 'gap' and typeB == 'telo' and startA < 500000 and startB - endA < distance_cutoff:
                    print(f"{chrom}\t0\t{endA}")
                # ----------------------------------------TELO-GAP----]
                # --------------------------------------------<<<<<<<<
                elif typeA == 'telo' and typeB == 'gap' and gsize[chrom] - endA < 500000 and startB - endA < distance_cutoff:
                    print(f"{chrom}\t{startB-1}\t{gsize[chrom]}")
                i += 1



if __name__ == '__main__':
    main()
