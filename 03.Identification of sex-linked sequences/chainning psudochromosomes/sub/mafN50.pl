#!/usr/bin/perl
#==========================================================================
#         FILE:  mafN50.pl
#  DESCRIPTION:  calculate maf segments N50
#==========================================================================


use strict;

my $map = shift; # scafMap.stat
my $info = shift; # identity.info

my $err = 100;

my %map;
open IN,$map;
while(<IN>){
	chomp;split;
	$map{$_[0]} = $_[4];
}
close IN;

my %info;
open IN,$info;
my @in = <IN>;
close IN;

foreach(@in){
	chomp;split;
	if($map{$_[6]} eq $_[1]){
		$info{$_[6]} += $_[3];
	}
}

foreach my $k(keys %info){
	$info{$k} /= 2;
}

my (%count,%N50,%has);
foreach(@in){
	chomp;split;
	if($map{$_[6]} eq $_[1]){
		if(!$has{$_[6]}){
			my $mid = $info{$_[6]};
			$count{$_[6]} += $_[3];
			if(abs($count{$_[6]} - $mid) <= $err || $count{$_[6]} >= $mid){
				$N50{$_[6]}{N} = $_[2];
				$N50{$_[6]}{mid} = $mid;
				$has{$_[6]} = 1;
			}
		}
	}
}

foreach my $k(keys %N50){
	print "$k\t$N50{$k}{N}\t$N50{$k}{mid}\n";
}

