#!/usr/bin/env python3
import sys
if len(sys.argv) < 3:
    sys.exit(f"python3 {sys.argv[0]} *.paf ref_id")

target_ref = sys.argv[2]
order = {}
lens = {}
with open(sys.argv[1], 'r') as fh:
    index = 1
    for i in fh:
        tmp = i.strip().split()
        qry = tmp[0]
        qry_len = tmp[1]
        ref = tmp[5]
        if ref != target_ref:
            continue
        else:
            target_ref_len = tmp[6]
        if qry not in lens:
            lens[qry] = qry_len

        if qry not in order:
            order[qry] = index
        else:
            order[qry] = order[qry] + index
        index += 1

top  = []
# sort qry id by ref corrds
for q in sorted(order.keys(), key = lambda kv:(kv[1], kv[0])):
    top.append(f"{q}:0:{lens[q]}")

# output karyotype.txt for linkview 
print(" ".join(top))
print(f"{target_ref}:0:{target_ref_len}")
