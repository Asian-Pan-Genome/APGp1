#!/usr/bin/perl

$/="\n>";
open(IN,$ARGV[0]);
while(<IN>){
	chomp;
	my ($id,$fa)=split(/\n/,$_,2);
	$id=~s/>//g;
	$fa=~s/\n//g;
	$fa=~s/\.//g;
	print ">$id\n$fa\n";
}
close IN;
