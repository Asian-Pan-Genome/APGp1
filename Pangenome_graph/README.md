# Graph construction, comparison, and mapping.

This repository includes the commands and workflows in pangenome graph analysis, including construction, comparison, and mapping.


## Graph construction

[Multiple graphs](https://github.com/Asian-Pan-Genome/APGp1#pangenome-graphs) are built from different assemblies using multiple reference backbones (T2T-CHM13, T2T-CN1 and GRCh38) using two methods.

### Minigraph-Cactus (MC) graph


* Testing the effect from iterative orders of assemblies



### Minigraph (MG) graph

```perl
#!/usr/bin/perl

my $ref = shift || die "usage: perl $0 ref AsmList threads output\n";
my $list = shift || die "";
my $threads = shift || die "";
my $output = shift || die "";

my $fastaDir = "./";

$cmd="minigraph -cxggs -t${threads} $ref ";

print "Checking files...\n\n";

if(-e $ref){
	print "$ref found ...\n";
}
else {
	print "ERROR: $ref NOT found !!! \n\n";
}

my $count=1;
open IN,"$list";
while (<IN>){
	chomp;
	$fasta=$_;
	if (-e $fasta){
		print "seq$count: $fasta1 found ...\n\n";
	}
	else {
		print "seq$count: $fasta1 NOT found !!!\n\n";
		print "ERROR!!!!!!!!!\n";
	}
	$cmd .= "$fasta ";
	$count+=1;
}

$cmd .= "> $output\n";

print "Running... \n$cmd\n\n";

system(qq($cmd));

print "Finished!\n\n";
```

> All the related pangenome graphs are available at the APG [portal]().

## Graph comparison 


## Graph mapping 
* NGS mapping from multiple ancestries.
