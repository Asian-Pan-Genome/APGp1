#!/usr/bin/env python3
import re
import sys

if len(sys.argv) < 3:
    sys.exit(f"python3 {sys.argv[0]} *.fasta.fai size")

end_size = int(sys.argv[2])

with open(sys.argv[1], 'r') as fh:
    for i in fh:
        tmp = i.strip().split()
        chrom, length = tmp[0], int(tmp[1])
        #if chrom.startswith("chr"):
        print(f"{chrom}\t0\t{end_size}\thead")
        end_win_start = length - end_size
        print(f"{chrom}\t{end_win_start}\t{length}\ttail")

