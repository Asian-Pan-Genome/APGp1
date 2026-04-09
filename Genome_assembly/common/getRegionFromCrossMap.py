#!/usr/bin/evn python3

import sys
#import argsparse
from icecream import ic

if len(sys.argv) < 2:
    print(f"python3 {sys.argv[0]} <*.cross>")
    exit()

def parser_crossmap(file):
    pre = []
    target_match = []
    with open(file, 'r') as fh:
        while True:
            line = fh.readline().strip()
            if not line:
                break
            tmp = line.strip().split("\t")
            if len(pre) == 0:
                target_match = [line,]
                pre = tmp[0:3]
            elif tmp[0:3] == pre:
                target_match.append(line)
            else:
                yield target_match
                target_match = [line,]
                pre = tmp[0:3]
        yield target_match



def main():
    if len(sys.argv) > 4:
        descs = getinfo(sys.argv[4])

    for arr in parser_crossmap(sys.argv[1]):
        first_line = arr[0]
        last_line = arr[-1]
        aa = first_line.split("\t")
        bb = last_line.split("\t")
        items = (len(aa) - 1 ) / 2
        items = int(items)
        if items >= 3:
            info = aa[3:items]
            info = "\t".join(info)
        ref = aa[0]
        ref_start = aa[1]
        ref_end = aa[2]
        qry = bb[items + 1]
        qry_start = aa[items+2]
        qry_end = bb[items+3]
        print(f"{ref}\t{ref_start}\t{ref_end}\t{qry}\t{qry_start}\t{qry_end}\t{info}")

if __name__ == "__main__":
    main()


