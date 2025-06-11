#! /usr/bin/perl

use warnings;

my $length_file = shift || die "<USAGE> perl $0 Reference_Chr_length_file window_size\t" ;
my $window_size = shift || die "<USAGE> perl $0 Reference_Chr_length_file window_size\t";

open IN, "$length_file";
open OUT,">$length_file.$window_size.windows";
while (<IN>){
	chomp;
	($chr, $length)=split(/\t/,$_);
	if ($length < $window_size){
	print OUT "$chr\t$chr\t1\t$length\n";
	}	
	else{
		foreach $i (0..($length/$window_size-1)){
			$s = $i*$window_size+1;
			$e = ($i+1)*$window_size;
			print OUT "$chr\_$i\t$chr\t$s\t$e\n";
		}
		$j=int($length/$window_size-1);
		$se=($j+1)*$window_size+1;
		$ee=$length;
		$temp=$j+1;
		print OUT "$chr\_$temp\t$chr\t$se\t$ee\n";
	}

}
