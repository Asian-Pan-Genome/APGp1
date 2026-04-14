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
            svtype = atrri['SVTYPE']
            if 'SVLEN' in atrri:
                svlen = int(atrri['SVLEN'])
                svlen = abs(svlen)
            else:
                svlen = len(fields[3])
            if 'END' in atrri:
                end = atrri['END']
            else:
                if svtype == "INS":
                    end = start + 1
                else:
                    #svtype == "DEL" or svtype == "INV":
                    end = start + svlen

            covered = 0
            for fmt in fields[9:]:
                if ":" in fmt:
                    gt = fmt.split(":")[0]
                    covered += gt.count("1")
                else:
                    covered += fmt.count("1")
            tsv = f"{fields[0]}\t{start}\t{end}\t{svtype}\t{svlen}\t{covered}"
            print(tsv)
