import sys
import numpy as np
import rich.progress

if len(sys.argv) == 1:
	print("Warning: Miss Parameter!")
	print(f"<Usage> python {sys.argv[0]} cov.file pas.file pos.file outname")
	sys.exit(1)

DepthFile = sys.argv[1]
PathFile = sys.argv[2]
PosFile = sys.argv[3]
Ofile = sys.argv[4]

path = np.zeros(72952839+1) # max node id in APG1d2 Graph
Total_depth = 0 # all aligned depth
True_depth = 0 # on-target depth

with open(PathFile,'r') as f:
	for line in f:
		path[int(line.strip('\n'))] = 1

nodePos = dict() # key : raw node id  value : position in Ref
with rich.progress.open(PosFile,"r") as f:
	for line in f:
		fields = line.strip('\n').split('\t')
		node = int(fields[0])
		chro = fields[1]
		start = fields[2]
		nodePos[node] = chro + "-" + start

with rich.progress.open(DepthFile,"r") as f, open(Ofile,"w") as outfile:
	next(f) # jump the first line
	for line in f:
		fields = line.strip('\n').split('\t')
		Raw_node = int(fields[0])
		Filt_node = int(fields[1])
		binCov = fields[2]
		nodeCov = fields[3]
		maxBinCov = fields[4]
		if path[Filt_node] == 1 : # on-target
			True_depth += int(nodeCov)
		else: # off-target
			# Note: xxx.gfa and xxx.d2.gbz have different node id
			pos = nodePos[Raw_node].split('-')
			# Output format: chro \t start \t end \t binCov \t maxBinCov
			chro = pos[0]
			start = pos[1]
			end = pos[1]
			outfile.write(chro + "\t" + start + "\t" + end + "\t" + binCov + "\t" + maxBinCov + "\n")
		Total_depth += int(nodeCov)

OnTargetRatio = True_depth / Total_depth
print(True_depth,Total_depth,OnTargetRatio)
print("Finish!")