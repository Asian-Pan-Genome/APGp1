import sys
import rich.progress

Input=sys.argv[1]

Output=Input+".info"

with rich.progress.open(Input,"r") as infile, open(Output,"w") as outfile:
	for line in infile:
		fields=line.strip('\n').split('\t')
		REF=fields[0]
		ALT=fields[1].split(',')
		
		# Bi-allele(0) or Multi-allele(1)
		if len(ALT) == 1:
			outfile.write("0\t")
		else:
			outfile.write("1\t")

		# Variation Type:
		# SNP   (0): ref_len && alt_len == 1 (priority 1)
		# MNP   (1): all allele len equal (priority 3)
		# Indel (2): has unique len allele (priority 4)
		# SV    (3): has allele len >= 50 (priority 2)

		max_len = len(REF)
		equal_flag = 1
		for i in range(len(ALT)):
			allele = ALT[i]
			if len(allele) > max_len:
				max_len = len(allele)
			if len(allele) != len(REF):
				equal_flag = 0

		if max_len == 1 and equal_flag == 1:
			outfile.write("0\n") #SNP
		elif max_len >= 50:
			outfile.write("3\n") #SV
		elif equal_flag == 1:
			outfile.write("1\n") #MNP
		else:
			outfile.write("2\n") #INDEL
