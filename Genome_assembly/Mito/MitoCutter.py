import sys
from Bio import SeqIO
from Bio.Seq import MutableSeq
import re

if len(sys.argv) != 4:
    print(f'Usage: python {sys.argv[0]} mito.fa mito2ref.paf out_prefix')
    print('This script is used to cut abnormally assembled mitochondrial genome into complete one')
    print('The outputs including $out_prefix.fasta and $out_prefix.agp')
    sys.exit(1)


def find_query_pos(pos=None, mito_start=None, cigar=None):
    cigars = re.findall('(\d+)(\D)', cigar)
    if cigars[0][1] =='S':
        sys.exit(f'Error!!! There is "S" in cigar. Mito_start = {mito_start}')
    else:
        ref_pos = 0
        qry_pos = 0
        for cigar in cigars:
            pre_ref_pos = ref_pos
            pre_qry_pos = qry_pos
            if cigar[1] == 'M':
                ref_pos += int(cigar[0])
                qry_pos += int(cigar[0])
                if ref_pos > pos:
                    return (mito_start + pre_qry_pos + pos - pre_ref_pos)
            elif cigar[1] == 'D':
                ref_pos += int(cigar[0])
                if ref_pos > pos:
                    return (mito_start + pre_qry_pos)
            elif cigar[1] == 'I':
                qry_pos += int(cigar[0])


record = list(SeqIO.parse(sys.argv[1], 'fasta'))[0]
seq = MutableSeq(str(record.seq))
with open(sys.argv[2], 'r') as f:
    lines = f.readlines()

if len(lines) == 1:
    mito_len, mito_start, mito_end = lines[0].strip().split('\t')[1:4]
    ref_len, ref_start, ref_end = lines[0].strip().split('\t')[6:9]
    if (int(ref_end) - int(ref_start)) < int(ref_len):
        sys.exit('Warning!!! This mitochondrial genome is partial')
    elif (int(ref_end) - int(ref_start)) == int(ref_len):
        if int(mito_start) == 0 and int(mito_end) == int(mito_len):
            sys.exit('No other copies were found')
        else:
            print(f'[{mito_start}, {mito_end})')
            #with open(f'{sys.argv[-1]}.agp', 'w') as f:
            #    f.write(f'chrM\t')
            record.seq = seq[int(mito_start):int(mito_end)]
            with open(f'{sys.argv[-1]}.fasta', 'w') as f:
                SeqIO.write(record, f, 'fasta')
    
elif len(lines) >= 2:
    mito_starts = []
    mito_ends = []
    ref_starts = []
    ref_ends = []
    cigars = []
    for line in lines[:2]:
        tmp = line.strip().split('\t')
        mito_starts.append(int(tmp[2]))
        mito_ends.append(int(tmp[3]))
        strand = tmp[4]
        if strand == '-':
            sys.exit('Error!!! This line:\n' + line + 'has "-" strand')
        ref_len = int(tmp[6])
        ref_starts.append(int(tmp[7]))
        ref_ends.append(int(tmp[8]))
        for tag in tmp[12:]:
            if tag.startswith('cg'):
                cigars.append(tag.split(':')[-1])
                break


    if (ref_ends[0] - ref_starts[0]) == ref_len:
        print(f'[{mito_starts[0]}, {mito_ends[0]})')
        record.seq = seq[mito_starts[0]:mito_ends[0]]
    elif ref_ends[0] != ref_len:
        if ref_starts[0] == 0:
            print(f'[{mito_starts[0]}, {mito_ends[0]}) + [{mito_starts[1]}, {mito_ends[1]})')
            record.seq = seq[mito_starts[0]:mito_ends[0]] + seq[mito_starts[1]:mito_ends[1]] 
        else:
            sys.exit('Error!!! Something wrong (line 87)')
    elif ref_starts[0] > 0 and ref_starts[1] == 0:
        mito_pos = find_query_pos(ref_starts[0], mito_starts[1], cigars[1])
        print(f'[{mito_starts[1]}, {mito_pos}) + [{mito_starts[0]}, {mito_ends[0]})')
        record.seq = seq[mito_starts[1]:mito_pos] + seq[mito_starts[0]:mito_ends[0]]
    else:
        sys.exit('Error!!! Something wrong (line 93)')

    with open(f'{sys.argv[-1]}.fasta', 'w') as f:
        SeqIO.write(record, f, 'fasta')
