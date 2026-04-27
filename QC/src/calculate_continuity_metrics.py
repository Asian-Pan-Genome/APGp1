import sys
import re
from Bio import SeqIO
import numpy as np
from math import log2


#if len(sys.argv) < 2:
#    print('Usage: python calculate_continuity_metrics.py asm.fa')
#    print('This script can simply calculate some metrics like assembly size, N40, N50, N60, auN and GCI')
#    sys.exit(1)


def complement_lengths(lengths=[], Ns_bed=[], length=None):
    last = 0
    n = len(Ns_bed)
    if n > 0:
        for i, segment in enumerate(Ns_bed):
            if i != n-1:
                if segment[0] > last:
                    lengths.append(segment[0] - last)
                last = segment[1]
            else:
                if segment[0] > last:
                    lengths.append(segment[0] - last)
                if length > segment[1]:
                    lengths.append(length - segment[1])
    else:
        lengths.append(length)
    

def merge_merged_depth_bed(Ns_bed=[], length=None):
    new_merged_depths_bed = []
    
    dist = length * 0.005
    start = 0
    end = length
    
    current_segment = (start, start)
    for segment in Ns_bed:
        if (segment[0] - current_segment[1]) <= dist:
            current_segment = (current_segment[0], segment[1])
        else:
            new_merged_depths_bed.append(current_segment)
            current_segment = segment
    if (end - current_segment[1]) <= dist:
        current_segment = (current_segment[0], end)
    new_merged_depths_bed.append(current_segment)
    return new_merged_depths_bed


def parse_fa(asm=None):
    scaf_lengths = []
    ctg_lengths = []
    new_merged_ctg_lengths = []
    pattern = re.compile(r'(?i)N+')
    for record in SeqIO.parse(asm, 'fasta'):
        scaf_lengths.append(len(record))
        Ns_bed = []
        for match in pattern.finditer(str(record.seq)):
            Ns_bed.append((match.start(), match.end()))
        complement_lengths(ctg_lengths, Ns_bed, len(record))
        Ns_bed = merge_merged_depth_bed(Ns_bed, len(record))
        complement_lengths(new_merged_ctg_lengths, Ns_bed, len(record))
    return np.array(scaf_lengths), np.array(ctg_lengths), np.array(new_merged_ctg_lengths)


def compute_N40(lengths=[]):
    n = 0
    lengths = sorted(lengths, reverse=True)
    cum = np.cumsum(lengths)
    for i, number in enumerate(cum):
        if number >= cum[-1] * 0.4:
            n = lengths[i]
            break
    return n


def compute_N50(lengths=[]):
    n = 0
    lengths = sorted(lengths, reverse=True)
    cum = np.cumsum(lengths)
    for i, number in enumerate(cum):
        if number >= cum[-1] * 0.5:
            n = lengths[i]
            break
    return n


def compute_N60(lengths=[]):
    n = 0
    lengths = sorted(lengths, reverse=True)
    cum = np.cumsum(lengths)
    for i, number in enumerate(cum):
        if number >= cum[-1] * 0.6:
            n = lengths[i]
            break
    return n


def compute_auN(lengths=[]):
    return sum(np.square(lengths)) / sum(lengths)


def compute_GCI(scaf_lengths=[], ctg_lengths=[], new_merged_ctg_lengths=[]):
    exp_n50 = compute_N50(scaf_lengths)
    exp_num_ctg = len(scaf_lengths)
    obs_n50 = compute_N50(ctg_lengths)
    obs_num_ctg = len(new_merged_ctg_lengths)

    return 100 * log2(obs_n50/exp_n50 + 1) / log2(obs_num_ctg/exp_num_ctg + 1)


if __name__=='__main__':
    if len(sys.argv) > 1:
        asm = sys.argv[1]
    else:
        asm = sys.stdin
    scaf_lengths, ctg_lengths, new_merged_ctg_lengths = parse_fa(asm)
    print(f'Assembly size:\t{sum(scaf_lengths)}\n')
    print('#Scaffold\t\t#Contig')
    print(f'N40:\t{compute_N40(scaf_lengths)}\t{compute_N40(ctg_lengths)}')
    print(f'N50:\t{compute_N50(scaf_lengths)}\t{compute_N50(ctg_lengths)}')
    print(f'N60:\t{compute_N60(scaf_lengths)}\t{compute_N60(ctg_lengths)}')
    print(f'auN:\t{compute_auN(scaf_lengths)}\t{compute_auN(ctg_lengths)}')
    print(f'\n\nGCI:\t{compute_GCI(scaf_lengths, ctg_lengths, new_merged_ctg_lengths)}')
