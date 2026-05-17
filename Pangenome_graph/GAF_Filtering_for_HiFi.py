import sys
import rich.progress
import argparse

#===================================
#	Filter the GAF
# 1. contain the hight score(AS) per read
# 2. remove the aligned length < threshold(80%)
# 3. remove MAPQ < threshold(1)
# 4. remove identity < threshold(90%)
#===================================


parser = argparse.ArgumentParser(description="Filter the GAF File")
parser.add_argument('-g','--GAF',required=True,metavar="",help='the name of input GAF file')
parser.add_argument('-l','--alignedLen',metavar="FLOAT",type=float,default=0.8,help='the fraction of algined length')
parser.add_argument('-m','--mapQ',metavar="INT",type=int,default=1,help='the threshold for MapQ')
parser.add_argument('-i','--identity',metavar="FLOAT",type=float,default=0.9,help='the threhold for identity')
args = parser.parse_args() # get all parameter

def FiltLine(line):
	# Filter the line
	# if good, return 1; else return 0
	if line == "":
		return 0
	
	col2 = float(line.split('\t')[1])
	col3 = float(line.split('\t')[2])
	col4 = float(line.split('\t')[3])
	Raligned = (col4 - col3) / col2 
	
	MapQ = int(line.split('\t')[11])
	Identity = float(line.split('\t')[15].split(':')[2])

	#print(Raligned,MapQ,Identity)

	if Raligned >= Taligned and MapQ >= Tmapq and Identity >= Tidentity:
		return 1
	else:
		return 0

if __name__ == '__main__':
	GAFfile = str(args.GAF)
	Taligned = args.alignedLen  # threshold for aligned length fraction
	Tmapq = args.mapQ   # threshold for MAPQ
	Tidentity = args.identity # threashold for identity

	CurSample = "-1"# Current Sample
	MaxAS = -1      # Store the Current Max AS value
	MaxASline = ""  # Store the Max Line

	ft = open(GAFfile+".filt",'w')

	with rich.progress.open(GAFfile,"r") as f:
		for line in f:
			sample = line.split('\t')[0]
			AS = float(line.split('\t')[13].split(':')[2]) 
			# Using AS as mapping score
			if sample != CurSample:
				# New Sample, Need to print the prevent read
				if FiltLine(MaxASline) == 1:
					ft.write(MaxASline)
				CurSample = sample
				MaxAS = -1
			if AS > MaxAS:
				MaxAS = AS
				MaxASline = line

	if FiltLine(MaxASline) == 1:
		ft.write(MaxASline)
	ft.close()
		
				
