#!/usr/bin/perl -w
use strict;
die "<genome.fa> <artificial_chrZ.order.txt>\n" unless @ARGV==2;
my %genome;
open IN,"$ARGV[0]" or die $!;
$/=">";
<IN>;
while(<IN>){
	chomp;
	$_=~/(.+?)\n/;
	my $id=(split /\s+/,$1)[0];
	$_=~s/.+?\n//;
	$_=~s/\s+//g;
	$genome{$id}=$_;
}
$/="\n";
close IN;

my @chrZ;
open IN,"$ARGV[1]" or die $!;
while(<IN>){
	chomp;
	my @A=split /\t/;
	my $string;
	#if($A[6] ne length($genome{$A[1]}) ){die "$_";}
	if($A[2] eq "+"){
		$string= uc ($genome{$A[1]});
	}elsif($A[2] eq "-"){
		$string= reverse ($genome{$A[1]});
		$string= uc $string;
		$string=~tr/ATCG/TAGC/;
	}
	push (@chrZ,$string);
}
close IN;

my $gap= "N" x 600;
my $Zseq=join("$gap",@chrZ);
my $count=0;
print ">chrZ\n";
while($Zseq=~/(.{80})/g){
	print "$1\n";
	$count++;
}
if($count*80<length($Zseq)){
	my $lastLine=substr($Zseq,$count*80);
	print "$lastLine\n";
}



