#!/usr/bin/perl
#==========================================================================
#         FILE:  msort.pl
#  DESCRIPTION:  
#==========================================================================

use strict;

my $N50 = shift;
my $Mv1 = shift;

my %N50;
open IN,$N50;
while(<IN>){
	chomp;split;
	$N50{$_[0]} = $_[1];
}
close IN;

open OUT,">$Mv1.N50";
open IN,$Mv1;
while(<IN>){
	chomp;split;
	print OUT "$_\t$N50{$_[4]}\n" if($N50{$_[4]});
}
close IN; close OUT;

my $msort = "./msort";

`$msort -k [m1,n11] $Mv1.N50 >$Mv1.m`;
`perl -n -e 'print "\$.\t\$_"' $Mv1.m >$Mv1.m.r`;

