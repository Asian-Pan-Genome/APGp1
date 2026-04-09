#!/usr/bin/env python3
import re
import sys

if len(sys.argv) < 3:
    sys.exit(f"python3 {sys.argv[0]} *.fasta.fai sort.gaps.bed")
gsize = {}
with open(sys.argv[1], 'r') as fh:
    for i in fh:
        tmp = i.strip().split()
        chrom, length = tmp[0], int(tmp[1])
        gsize[chrom] =  length

slop = 10000
gcount = 0
with open(sys.argv[2], 'r') as fh:
    for i in fh:
        gcount += 1
        tmp = i.strip().split()
        chrom, gstart, gend = tmp[0], int(tmp[1]), int(tmp[2])
        if gstart - slop > 0:
            gstart_slop =  gstart - slop
        else:
            gstart_slop = 0

        if gend + slop > gsize[chrom]:
            gend_slop = gsize[chrom]
        else:
            gend_slop = gend + slop

        gid_l = chrom.split("_")[0] + "_g" + str(gcount) + "_left"
        gid_r = chrom.split("_")[0] + "_g" + str(gcount) + "_right"
        print(f"{chrom}\t{gstart_slop}\t{gstart}\t{gid_l}")
        print(f"{chrom}\t{gend}\t{gend_slop}\t{gid_r}")
