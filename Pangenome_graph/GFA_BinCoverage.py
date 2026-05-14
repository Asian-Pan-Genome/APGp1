import sys
import math
import rich.progress

if len(sys.argv) != 5:
	print('ERROR:MISS PARAMETER')
	print(f'Usage: python {sys.argv[0]} <Coverage.stat.file> <mapping.tsv> <bin.lenght(bp)> <output.name>')
	sys.exit(1)

StatFile = sys.argv[1]
MappingFile = sys.argv[2]
BinLen = int(sys.argv[3])
OutName = sys.argv[4]

print(f'>>>> start to run with Bin Length: {BinLen}bp ... ')

CurNode = "-1"
CurDepth = 0
CurNum = 0
MaxDepth = 0
FlagBin = 1 # whether the bin is the first bin of one node
Start = 1 
NodeCov = 0 # total coverage of one node

MappingDict = dict()

with open(MappingFile,'r') as f:
	for line in f:
		RawNode = line.strip().split('\t')[1]
		NewNode = line.strip('\n').split('\t')[2].split(',')
		#print(NewNode)
		for node in NewNode:
			MappingDict[node] = RawNode
#print(MappingDict)
print(">>>> Construct Mapping Dict Finish!")


RawNode = "-1"
ft = open(OutName,'w')


with rich.progress.open(StatFile,"r") as f:
	next(f) #jump the first line
	for line in f:
		node = line.strip().split('\t')[1]
		coverage = int(line.strip('\n').split('\t')[3])
		#print(f">>>>>node:{node} coverage:{coverage}")
		if node != CurNode:
			# start a new node
			#print("Start a new node")
			if CurNum != 0:
				#print("Still need to print")
				AvgDepth = str(math.ceil(CurDepth / CurNum))
				if int(AvgDepth) > MaxDepth:
					MaxDepth = int(AvgDepth)
				if FlagBin == 1:
					tmpline = RawNode + "\t" + CurNode + "\t" + AvgDepth
				else:
					tmpline = "," + AvgDepth
				ft.write(tmpline) 
			if Start == 1:
				Start = 0
				ft.write("Raw.node\tFilt.node\tCoverage(Bin="+str(BinLen)+")\tTotal.Coverage\tMax.Bin\n")
			else:
				ft.write("\t"+str(NodeCov)+"\t"+str(MaxDepth))
				ft.write("\n")
				NodeCov = 0
			FlagBin = 1
			CurNode = node
			CurNum = 0
			CurDepth = 0
			MaxDepth = 0
			RawNode = MappingDict[CurNode]
			#print(f"Current Node:{node} Raw Node:{RawNode}")
		if node == CurNode:
			NodeCov += coverage
			CurNum += 1
			CurDepth += coverage
			#print(f"Current Number of bp:{CurNum}  Current Depth:{CurDepth} Bin Length:{BinLen}")
			if CurNum == BinLen:
				#print("Output a bin")
				AvgDepth = str(math.ceil(CurDepth / CurNum))
				CurDepth = 0
				CurNum = 0
				if FlagBin == 1:
					tmpline = RawNode + "\t" + node + "\t" + AvgDepth
					FlagBin = 0
				else:
					tmpline = "," + AvgDepth
				ft.write(tmpline)
				if int(AvgDepth) > MaxDepth:
					MaxDepth = int(AvgDepth)
if CurNum != 0:
	AvgDepth = str(math.ceil(CurDepth/CurNum))
	if int(AvgDepth) > MaxDepth:
		MaxDepth = int(AvgDepth)
	if FlagBin == 1:
		tmpline = RawNode + "\t" + CurNode + "\t" + AvgDepth
	else:
		tmpline = "," + AvgDepth
	ft.write(tmpline)
ft.write("\t"+str(NodeCov)+"\t"+str(MaxDepth))
ft.close() 
print("Finish!")
