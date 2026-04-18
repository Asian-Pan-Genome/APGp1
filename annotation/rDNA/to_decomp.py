import argparse
import sys
import os
import textwrap

parser = argparse.ArgumentParser(prog='to_decomp',
                                 formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description=textwrap.dedent('''\
Description
    Decompose rDNA unit from the blastn result
'''))

parser.add_argument('-bed', metavar='<file>', help='input tbl file')
parser.add_argument('-len', metavar='<INT>', type=int, default=13332, help='the coding sequnece length')
parser.add_argument('-tol', metavar='<INT>', type=int, default=0, help='The length that tolerate the alignment to be viewed as a valid coding sequence. For example, if the cordinate [a, b] of the coding sequence mapping to the assembly, the aligmnent is cosidered to a valid coding seuqence if a < $tol and $len - b < $tol')


if len(sys.argv) == 1:
    parser.print_help()
    parser.exit()

args = parser.parse_args()

def readTBL(fh):
    tblinfo = {}
    for line in fh:
        line = line.rstrip()
        line = line.replace("\n", "")
        lining = line.split("\t")
        qu_s = min(int(lining[8]), int(lining[9]))
        qu_e = max(int(lining[8]), int(lining[9]))
        if int(lining[8]) > int(lining[9]):
            dic = "-"
        else:
            dic = "+"
        if qu_s - 1 + args.len - qu_e <= args.tol:
            if lining[0] not in tblinfo:
                tblinfo[lining[0]] = [[int(lining[6]),int(lining[7]),dic]]
            else:
                tblinfo[lining[0]].append([int(lining[6]), int(lining[7]), dic])
    return tblinfo

with open(args.bed, 'r') as fh:
    tblinfo = readTBL(fh)
for ids in tblinfo.keys():
    i = 0
    end = len(tblinfo[ids])
    for line in sorted(tblinfo[ids], key=lambda info: info[0]):
        if i == 0:
            pre_s = line[0]
            pre_e = line[1]
            pre_dic = line[2]
            i = i + 1
            continue
        if pre_dic == "+" and line[2] == "+":
            print("%s\t%i\t%i\trDNA\t0\t+" % (ids, pre_s - 1, line[0] - 1))
        elif pre_dic == "-" and line[2] == "-":
            print("%s\t%i\t%i\trDNA\t0\t-" % (ids, pre_e, line[1]))
        elif pre_dic == "+" and line[2] == "-":
            print("%s\t%i\t%i\trDNA\t0\t+-" % (ids, pre_s - 1, line[1]))
        pre_s = line[0]
        pre_e = line[1]
        pre_dic = line[2]
        i = i + 1