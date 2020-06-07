#!/usr/bin/perl -w
# zhangpei@genomics.cn
use strict;
die "perl $0 <rpkm>" unless @ARGV==1;
my@file=glob 'part*/part*.num';
my$total=0;
my%rpkm;
foreach my$ele(@file){
	open IN,"$ele";
	while(<IN>){
		chomp;
		my@A=split(/\t/);
		$rpkm{$A[0]}{num}=$A[1];
		$rpkm{$A[0]}{len}=$A[2];
		$total=$total+$rpkm{$A[0]}{num};
	}
	close IN;
}
open OUT,">$ARGV[0]";
foreach my$key(keys %rpkm){
	my$rpkm=$rpkm{$key}{num}*1000*1000000/$rpkm{$key}{len}/$total;
	print OUT "$key\t$rpkm\t$total\t$rpkm{$key}{num}\t$rpkm{$key}{len}\n";
}
close OUT;
