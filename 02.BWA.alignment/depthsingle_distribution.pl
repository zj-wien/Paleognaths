#!/usr/bin/perl -w
use strict;
die "<all.soapcoverage>\n" unless @ARGV==1;
my %hash;
if($ARGV[0]=~/\.gz$/){
	open IN,"gunzip -c $ARGV[0] |" or die $!;
}else{
	open IN,"$ARGV[0]" or die $!;
}
while(<IN>){
	chomp;
	if($_=~/^>/){next;}
	my @A=split /\s+/;
	foreach my $dep (@A){
		$hash{$dep}++;
	}
}
close IN;

my ($basenum,$totalDep)=(0,0);
print "#Dep\tfrequency\n";
foreach my $dep (sort{$a<=>$b} keys %hash){
	print "$dep\t$hash{$dep}\n";
	$basenum+=$hash{$dep};
	$totalDep+= ($hash{$dep} * $dep);
}

my $everageDep=sprintf "%.4f",$totalDep/$basenum;
print "#everageDepth: $everageDep\n";



