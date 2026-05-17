import sys
import rich.progress
import argparse

#===================================
# Filter the GAF(NGS,vg giraffe)
# 1. remove the reads with no alignment
# 2. remove aligned fraction != 100%
#===================================


parser = argparse.ArgumentParser(description="Filter the GAF File")
parser.add_argument('-g','--GAF',required=True,metavar="",help='the name of input GAF file')
args = parser.parse_args() # get all parameter

if __name__ == '__main__':
	GAFfile = str(args.GAF)

	ft = open(GAFfile+".filt",'w')

	with rich.progress.open(GAFfile,"r") as f:
		for line in f:
			startAlign = line.split('\t')[2]
			endAlign = line.split('\t')[3]
			Length = int(line.split('\t')[1])
			if startAlign != "*" :
				ratio = (float(endAlign) - float(startAlign)) / Length
				if ratio == 1.0:
					ft.write(line)
	ft.close()
