#!/usr/bin/env python3
import sys
import gzip

def smart_open(path, mode='rt'):
    if path == '-':
        return sys.stdin if 'r' in mode else sys.stdout
    if path.endswith('.gz'):
        return gzip.open(path, mode)
    return open(path, mode)

infile = sys.argv[1]
outfile = sys.argv[2]

with smart_open(infile, 'rt') as fin, smart_open(outfile, 'wt') as fout:
    for line in fin:
        if line.startswith('#'):
            fout.write(line)
            continue
        parts = line.rstrip('\n').split('\t')
        format_col = parts[8]
        sample_col = parts[9]
        gt_idx = format_col.split(':').index('GT')
        gt = sample_col.split(':')[gt_idx]
        if '.' in gt:
            continue
        fout.write(line)
