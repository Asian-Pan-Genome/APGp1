#!/usr/bin/env python

import sys
#from icecream import ic

if len(sys.argv) < 2:
    print("filter small contigs; filter BDN,DUP; keep genetype=1/1 or dv/(dr+dv) > 0.7; ")
    sys.exit(f"python3 {sys.argv[0]} *.sniffles.vcf")


def attribution2dict(format_string, format_var):
    d = {}
    a = format_string.split(":")
    b = format_var.split(":")
    for i,j in zip(a,b):
        d[i] = j

    return d

with open(sys.argv[1], "r") as f:
    for line in f:
        line = line.rstrip()
        if line.startswith("#"):
            print(line)
        else:
            fields = line.split("\t")
            if fields[0].startswith("chr") == False:
                continue
            if 'BND' in fields[2]: # only keep INS, DEL, and DUP
                continue
            info = attribution2dict(fields[-2], fields[-1])
            if info.get("GT"):
                if info.get("DR") and info.get("DV"):
                    if info['GT'] == '1/1':
                        print(line)
                    elif info['GT'] == '0/1':
                        dv_dr_rate = int(info['DV']) / (int(info['DR']) + int(info['DV']))
                        if dv_dr_rate > 0.7:
                            print(line)
                else:
                    sys.exit("Bad format of DR/DV")
            else:
                sys.exit("Bad format of GT")
