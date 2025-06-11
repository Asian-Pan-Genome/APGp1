#! /usr/bin/perl
#use warnings;

$window = shift || die "<USAGE> perl $0 window depth_file\n";
$depth_file = shift || die "<USAGE> perl $0 window depth_file\n";

###statistic
open IN,"$window";
open IN1,"$depth_file";
open OUT,">$depth_file\_stat";

$i=0;
my $sum;
my $length;
my $id;
my $chr1;
my $start;
my $end;

while (<IN>){
	chomp;
	($id,$chr1,$start,$end)=split(/\t/,$_);
	$length=$end-$start+1;
	$sum=0;
	if ($i>0){
		if($chr20 eq $chr1 && $pos0 >= $start && $pos0 <=$end){
			$sum+=$dep0;
		}
		else{
			print OUT $id."\t".$chr1."\t".$start."\t".$end."\t"."0"."\n";
			next;
		}
	}
	$i+=1;
	while (<IN1>){
		chomp;
		($chr2,$pos,$dep)=split(/\t/,$_);
		if($chr2 eq $chr1 && $pos >= $start && $pos <=$end){
			$sum+=$dep;
		}
		else{
			$ave=$sum/$length;
			print OUT $id."\t".$chr1."\t".$start."\t".$end."\t".$ave."\n";
			$dep0=$dep;
			$chr20=$chr2;
			$pos0=$pos;
			last;
		}
	}
}
$ave=$sum/$length;
print OUT $id."\t".$chr1."\t".$start."\t".$end."\t".$ave."\n";

