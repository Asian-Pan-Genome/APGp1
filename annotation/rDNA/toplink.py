import argparse
import subprocess
import sys
import textwrap
import re

parser = argparse.ArgumentParser(prog='fastaChain',
                                 formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description=textwrap.dedent('''\
Description
     Transfer the bed to plink.
'''))
parser.add_argument('-info',  metavar='<file>', help='input info file')
parser.add_argument('-bed', metavar='<STR>', help='input bed file')

if len(sys.argv) == 1:
    parser.print_help()
    parser.exit()

args = parser.parse_args()

def readbed(fh):
    idset = set()
    sample_col = {}
    for line in fh:
        line = line.rstrip()
        line = line.replace("\n","")
        lineing=line.split('\t')
        idset.add(lineing[3])
        sample = lineing[6].split(";")
        for sample_id in sample:
            if sample_id in sample_col:
                sample_col[sample_id].append([int(lineing[3].replace("SNP_","")), lineing[3], lineing[5]])
            else:
                sample_col[sample_id] = [[int(lineing[3].replace("SNP_","")), lineing[3], lineing[5]]]
    return idset, sample_col

def readinfo(fh):
    snpinfo = {}
    for line in fh:
        line = line.rstrip()
        line = line.replace("\n","")
        lineing=line.split('\t')
        snpinfo[lineing[0]] = lineing[1]
    return snpinfo

with open(args.bed, 'r') as fh:
    idset, sample_col = readbed(fh)

with open(args.info, 'r') as fh:
    snpinfo = readinfo(fh)

allids = set(sample_col.keys())
#print(sample_col)
for ids in allids:
    #for a in sample_col[ids]:
    #    if not len(a) == 3:
    #        print(a)
    snpset = set([a[1] for a in sample_col[ids]])
    #print(sample_col[ids])
    #print()
    nosnp = idset.difference(snpset)
    #print(len(nosnp))
    addition = [[int(nosnpid.replace("SNP_","")),nosnpid,"%s:%s" % (snpinfo[nosnpid],snpinfo[nosnpid])] for nosnpid in nosnp]
    sample_col[ids] = sample_col[ids] + addition
    sample_col[ids].sort()
    snpstr = ""
    presnps = [0]
    #print(len(sample_col[ids]))
    for snps in sample_col[ids]:
        if presnps[0] == snps[0]:
            presnps = snps
            continue
        presnps = snps
        if snpstr == "":
            snpstr = snps[2].replace(":"," ")
        else:
            snpstr = snpstr + "\t" + snps[2].replace(":"," ")

    print("%s\t%s\t0\t0\t1\t2\t%s" % ("AS",ids,snpstr))

