#!/usr/bin/env python
import os
import sys
import gzip
#from icecream import ic

if len(sys.argv) < 2:
    sys.exit(f"python3 {sys.argv[0]} *.survivor.vcf")

def smart_open(file, opera):
    if opera == 'r':
        if os.path.exists(file) ==False:
            print("Can not open file {}".format(file))
            exit()
        else:
            if file.endswith(".gz"):
                out = gzip.open(file, 'rt')
            else:
                out = open(file, 'r')
    elif opera == 'w':
        if file.endswith(".gz"):
            out = gzip.open(file, 'wt')
        else:
            out = open(file, 'w')
    return out

def attribution2dict(format_string):
    atrri = {}
    a = format_string.split(";")
    for i in a:
        if "=" not in i:
            continue
        b = i.split("=")
        atrri[b[0]] = b[1]

    return atrri


with smart_open(sys.argv[1], "r") as f:
    for line in f:
        line = line.rstrip()
        if line.startswith("#"):
            continue
        else:
            fields = line.split("\t")
            if fields[0].startswith("chr") == False:
                continue
            start = int(fields[1]) - 1
            atrri = attribution2dict(fields[7]) # SVTYPE=DUP;END=143893;SVLEN=48
            ac = atrri['AC']
            reflen = len(fields[3])
            altlen = len(fields[4])
            if reflen == altlen:
                continue
            elif reflen > altlen:
                svtype = "DEL"
                svlen = reflen - altlen
            else:
                svtype = "INS"
                svlen = altlen - reflen

            end = start + svlen
            if svlen > 49:
                print(f"{fields[0]}\t{start}\t{end}\t{svtype}\t{svlen}\t{ac}")
