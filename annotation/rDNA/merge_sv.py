import argparse
import itertools
import os.path
import subprocess
import sys
import textwrap
import re
import gzip
import io
from Bio.Seq import Seq

parser = argparse.ArgumentParser(prog='merge variants via coordinate',
                                 formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description=textwrap.dedent('''\
Description
merge variants file
'''))

parser.add_argument('-bed',  metavar='<file>', help='input fasta file')
parser.add_argument('-n',  metavar='STR', default="ChrB",help='input chromosome')

if len(sys.argv) == 1:
    parser.print_help()
    parser.exit()

args = parser.parse_args()

def readInfo(fh):
    svlib = []
    for line in fh:
        line = line.rstrip()
        line = line.replace("\n", "")
        lining = line.split("\t")
        info_str = lining[6]
        info = {}
        for info_part in info_str.split(";"):
            info[info_part.split("=")[0]] = info_part.split("=")[1]
        sv_type = re.sub(r'[0-9]', '', lining[3])
        svlib.append([lining[0],int(lining[1]),int(lining[2]),sv_type,lining[5],info])
        #svlib.sort(key=lambda svlib: (svlib[3], svlib[4], svlib[1]))
    return svlib

def merge_init(svlib):
    pre_sv = ("",0,0,"","")
    sample_name = []
    for sv in svlib:
        cur_sv = (sv[0],sv[1],sv[2],sv[3],sv[4])
        if pre_sv == cur_sv:
            sample_name.append(sv[5][args.n])
        else:
            if pre_sv == ("",0,0,"",""):
                pre_sv = cur_sv
                sample_name.append(sv[5][args.n])
                continue
            print("%s\t%i\t%i\t%s\t%i\t%s\t%s" % (pre_sv[0],pre_sv[1],pre_sv[2],pre_sv[3],len(sample_name),pre_sv[4],";".join(sample_name)))
            sample_name = []
            sample_name.append(sv[5][args.n])
            pre_sv = cur_sv
    print("%s\t%i\t%i\t%s\t%i\t%s\t%s" % (pre_sv[0],pre_sv[1],pre_sv[2],pre_sv[3],len(sample_name),pre_sv[4],";".join(sample_name)))
with open(args.bed, 'r') as fh:
    svlib = readInfo(fh)

merge_init(svlib)
