#!/usr/bin/env python
import os
import re
import sys
import gzip
#from icecream import ic

if len(sys.argv) < 2:
    print("change contig ID from CN1v1_Hap_chr* to chr*")
    sys.exit(f"python3 {sys.argv[0]} *.MC.vcf")

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
            print(line)
        else:
            tmp = line.split("\t")
            if tmp[7] != ".":
                info = tmp[7].split(";")
                new_info = ";".join(info[:3])
                tmp[7] = new_info
                new_out = "\t".join(tmp)
                print(new_out)
