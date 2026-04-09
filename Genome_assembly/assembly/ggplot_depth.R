#R ggplot2 coverage
# USAGE: Rscript $0 Arg1

library(ggplot2)

args<-commandArgs(T);

#Window Contig Start End Depth
data <- read.table(args[1], header=F);

pic <- ggplot(data,aes(x=V4/1000,y=V5))+geom_point(size=as.numeric(args[2]),alpha=0.5)+facet_wrap("as.character(data$V2)",ncol=as.numeric(args[3]))+ggtitle(args[1])+xlab("Contig/kb")+ylab("Depth/X")+ylim(0,100)

ggsave(pic,file=paste(args[1],"pdf", sep="."), width=210, height=697, units="mm", device="pdf")
