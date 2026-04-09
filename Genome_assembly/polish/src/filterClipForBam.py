#!/usr/bin/env python3
import sys
import re
import pysam
import argparse
import os
#from icecream import ic

def get_both_side_clip(cigar_string):
    try:
        # get left clipping base
        left_clip = re.search('^(\d+)[SH]\S+', cigar_string).group(1)
    except:
        left_clip = 0
    try:
        right_clip = re.search('(\d+)[SH]$', cigar_string).group(1)
    except:
        right_clip = 0
    return (int(left_clip), int(right_clip))


def filter_clip_by_perc(bam, output, clip_percent=0.1, force=False):
    total_good = 0
    removal = 0
    if os.path.exists(output) and force == False:
        print(f'[ERROR]: The file {output} exists\nPlease using "-f" or "--force" to rewrite', file=sys.stderr)
        raise SystemExit
    samfile = pysam.AlignmentFile(bam, 'rb')
    with pysam.AlignmentFile(output, 'wb', template=samfile) as outf:
        for segment in samfile.fetch():
            if (segment.is_mapped == True) and (segment.is_secondary == False):
                total_good += 1
                S = segment.get_cigar_stats()[0][4]
                H = segment.get_cigar_stats()[0][5]
                query_length = segment.infer_query_length()
                if ((S+H)/query_length <= clip_percent):
                    outf.write(segment)
                else:
                    removal += 1
    print(f"Total fine mapped: {total_good}", file=sys.stdout)
    print(f"Total Removal: {removal}", file=sys.stdout)
    samfile.close()

def filter_clip_by_base(bam, output, clip_base=1000, exempt_end=100, force=False):
    total_good = 0
    removal = 0
    if os.path.exists(output) and force == False:
        print(f'[ERROR]: The file {output} exists\nPlease using "-f" or "--force" to rewrite', file=sys.stderr)
        raise SystemExit
    samfile = pysam.AlignmentFile(bam, 'rb')
    with pysam.AlignmentFile(output, 'wb', template=samfile) as outf:
        for segment in samfile.fetch():
            if (segment.is_mapped == True) and (segment.is_secondary == False):
                total_good += 1
                ref_length = samfile.get_reference_length(segment.reference_name)
                cigar_string = segment.cigarstring
                M = segment.get_cigar_stats()[0][0]
                appr_reference_end = segment.reference_start + M
                # Do not conduct filtering if the alignment is located at least {exempt_end} bp from a target sequence end
                #  (to prevent clipping due to contig which could otherwise cause false alignment filtering).
                if segment.reference_start < exempt_end or ref_length - appr_reference_end < exempt_end:
                    continue
                if 'S' in cigar_string or 'H' in cigar_string:
                    left_clip, right_clip = get_both_side_clip(cigar_string)
                    if left_clip < clip_base and right_clip < clip_base:
                        outf.write(segment)
                    else:
                        removal += 1
                else:
                    outf.write(segment)
    print(f"Total fine mapped: {total_good}", file=sys.stdout)
    print(f"Total Removal: {removal}", file=sys.stdout)
    samfile.close()


if __name__=='__main__':
    desc = f"""
    This script is to filter bam file by clipping precent or base,
    and with mapping quality.

    Usage: python3 {sys.argv[0]} input_bam -o output.bam
    """
    parser = argparse.ArgumentParser(prog=sys.argv[0], add_help=False,
                                  formatter_class=argparse.RawDescriptionHelpFormatter,
                                  description=desc)

    group_io = parser.add_argument_group("Input/Output")
    group_io.add_argument('bam', metavar='ALIGNMENT-FILE', help='Long reads alignment files (at least one bam file)')
    group_io.add_argument('-o', '--output', metavar='STR', help='output file name', required=True)

    group_fo = parser.add_argument_group("Filter Options")
    group_fo.add_argument('-cp', '--clipped_amount', metavar='FLOAT', type=float,
                       help='Maximum clipped percentage of the reads [0,1] OR Maximum clipped base allowed if [INT] > 1', default=1000)

    group_op = parser.add_argument_group("Other Options")
    group_op.add_argument('-f', '--force', action='store_const', help='Force rewriting of existing files', const=True, default=False)
    group_op.add_argument('-h', '--help', action="help", help="Show this help message and exit")
    args = vars(parser.parse_args())
    #print(f'Used arguments:{args}')
    infile = args['bam']
    if os.path.exists(infile) == False  or os.access(infile, os.R_OK) == False:
        print(f'[ERROR]: "{infile}" is not an available file', file=sys.stderr)
        raise SystemExit
    if os.path.exists(infile + ".bai") == False  or os.access(infile + ".bai", os.R_OK) == False:
        print(f'[ERROR]: "{infile}" does not have index file', file=sys.stderr)
        raise SystemExit

    if args['clipped_amount'] >= 1:
        filter_clip_by_base(args['bam'], args['output'], clip_base=args['clipped_amount'], force=args['force'])
    else:
        filter_clip_by_perc(args['bam'], args['output'], clip_percent=args['clipped_amount'], force=args['force'])
