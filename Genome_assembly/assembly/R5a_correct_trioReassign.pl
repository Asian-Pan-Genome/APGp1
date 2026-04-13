#!/usr/bin/perl

my $famID=shift || die "usage: perl $0 FamID";

$comfa="${famID}.fa";

system(qq(cat ${famID}_hifiasm_hic_ont.hic.hap*_ctg.fa > $comfa));

${yak2}="/path-to-dir/NGS/${famID}-02/2.yak";
${yak3}="/path-to-dir/NGS/${famID}-03/3.yak";

system(qq(cat ${famID}_hifiasm_hic_ont.hic.hap*_ctg.ye | grep "^S" > ${famID}_combined.yak));

open IN,"$comfa";
while (<IN>){
	chomp;
	if(/^>/){
		s/>//;
		$ctg=$_;
	}
	else {
		$hash{$ctg}.=$_;
	}
}
close IN;

open IN1,"${famID}_combined.yak";
while (<IN1>){
	chomp;
	($s, $ctg, $patmer, $matmer, $ll, $ly, $yl, $yy)=split(/\t/,$_);
	if(($ll ==0) && ($yy >0)){
		$phasectg{$ctg}="mat";
	}
	elsif (($ll >0) && ($yy ==0)){
		$phasectg{$ctg}="pat";
	}
	elsif (($ll ==0) && ($yy ==0)){
		$phasectg{$ctg}="unphase";
	}
	elsif ($ll/$yy >=1.5){
		$phasectg{$ctg}="pat";
	}
	elsif ($ll/$yy <=0.6){
		$phasectg{$ctg}="mat";
	}
	else {
		$phasectg{$ctg}="unphase";
	}
}
close IN1;

open OUT1,">$comfa\_trioC_pat";
open OUT2,">$comfa\_trioC_mat";
open OUT3,">$comfa\_trioC_unknown";

foreach $i (sort keys %phasectg){
	print ${i}."\t".$phasectg{$i}."\t".length($hash{$i})."\n";
	if($phasectg{$i} eq "pat"){
		print OUT1 ">".${i}."\n".$hash{$i}."\n";
	}
	if($phasectg{$i} eq "mat"){
		print OUT2 ">".${i}."\n".$hash{$i}."\n";
	}
	if($phasectg{$i} eq "unphase"){
		print OUT3 ">".${i}."\n".$hash{$i}."\n";
	}
}
close OUT1;
close OUT2;
close OUT3;

###stat
print "##calculating N50\n";
system(qq(N50 $comfa\_trioC_pat $comfa\_trioC_pat.n50 10000));
system(qq(N50 $comfa\_trioC_mat $comfa\_trioC_mat.n50 10000));
system(qq(N50 $comfa\_trioC_unknown $comfa\_trioC_unknown.n50 10000));

###TrioEval
print "##Yak Trioeval\n";
system(qq(yak trioeval ${yak2} ${yak3} $comfa\_trioC_pat > $comfa\_trioC_pat.ye));
system(qq(yak trioeval ${yak2} ${yak3} $comfa\_trioC_mat > $comfa\_trioC_mat.ye));

###synteny to T2T-CHM13
print "##$comfa\_pat synteny to CHM13...\n";
system(qq(sh /path-to-dir/software/unimap_plot/run_unimap_dotplot.sh /path-to-dir/Reference/CHM13v2m.fasta $comfa\_trioC_pat $comfa\_trioC_pat));
print "##$comfa\_mat synteny to CHM13...\n";
system(qq(sh /path-to-dir/software/unimap_plot/run_unimap_dotplot.sh /path-to-dir/Reference/CHM13v2m.fasta $comfa\_trioC_mat $comfa\_trioC_mat));

