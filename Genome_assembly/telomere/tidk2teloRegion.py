#!/usr/bin/env python3
import sys

if len(sys.argv) < 2:
    sys.exit(f"python3 {sys.argv[0]} tidk.search.result [cutoff|default=0.5]")

def main():
    if len(sys.argv) > 2:
        cutoff = float(sys.argv[2])
    else:
        cutoff = 0.5
    count = 0
    with open(sys.argv[1], 'r') as fh:
        for i in fh:
            if i.startswith("id"):
                # id,window,forward_repeat_number,reverse_repeat_number,telomeric_repeat
                continue
            tmp = i.strip().split(",")
            chrid,window,forward_repeat_number,reverse_repeat_number,telomeric_repeat = tmp
            repeat_monomer_len = len(telomeric_repeat)
            total_repeat_number = int(forward_repeat_number) + int(reverse_repeat_number)
            total_repeat_length = total_repeat_number * repeat_monomer_len
            if count == 0:
                # the first record
                interval = int(window)
            start = int(window) - interval
            end = int(window)
            telo_coverage = total_repeat_length / interval
            if telo_coverage >= cutoff:
                print(f"{chrid}\t{start}\t{end}\t{telo_coverage}")
            count += 1

if __name__ == '__main__':
    main()

