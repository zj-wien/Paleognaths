#!/usr/bin/perl
#==========================================================================
#         FILE:  qtnetM.pl
#==========================================================================

use strict;

my $file = shift;

my (%N,%pos);
open IN,$file;
while(<IN>){
	if (/^#/){
		next;
	}
	chomp;split;
	my $v = $_;
	$v =~ s/$_[0]\t//;
	$N{$_[0]} = $v;
	$pos{$_[5]}{$_[0]} = $_[8];
}
close IN;
my @N;
foreach my $k(keys %pos){
	my ($NN,$size);
	foreach my $kk(keys %{$pos{$k}}){
		my $v = $pos{$k}{$kk};
		if($v > $size){
			$size = $pos{$k}{$kk};
			$NN = $kk;
		}
	}
	push @N,$NN;
}
foreach my $k(sort {$a <=> $b} @N){
	print "$N{$k}\n";
}

