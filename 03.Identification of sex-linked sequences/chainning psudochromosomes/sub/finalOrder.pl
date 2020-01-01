#!/usr/bin/perl
#==========================================================================
#         FILE:  finalOrder.pl
#==========================================================================

use strict;
my $all = shift; # query.sizes
my $use = shift; # maf_Identity_Coverage.txt
my $map = shift; # identity.info
my $order = shift; # scafOrderM.txt
my $out = shift;

`mkdir -p $out` unless(-d $out);
my %all;
open IN,$all;
while(<IN>){
	chomp;split;
	$all{$_[0]} = $_[1];
}
close IN;

my %map;
open IN,$map;
while(<IN>){
	chomp;split;
	$map{$_[6]} = 1;
}
close IN;

my (%order,%orderscaf);
open IN,$order;
while(<IN>){
	next if /^#/;
	chomp;split;
	$order{$_[0]}{$_[5]}{line} = $_;
	$order{$_[0]}{$_[5]}{chr} = $_[1];
	$orderscaf{$_[5]}{$_[1]} = 1;
}
close IN;

my $chrout = "$out/chrOder";
`mkdir -p $chrout` unless(-d $chrout);
my (%icscaf,%IC,$icchr);
open IN,$use;
while(<IN>){
	next if /^#/;
	chomp;split;
	next unless($orderscaf{$_[6]}{$_[1]} == 1);
	$icscaf{$_[6]} = 1;
	if($_[1] ne $icchr){
		if($icchr){
			close CO;
		}
		$icchr = $_[1];
		open CO,">$chrout/$icchr.syn";
		$icchr = $_[1];
	}
	print CO "$_\n";
}
close IN; close CO;

open O1,">$out/scafOrderM_M.txt";
open O2,">$out/map_order.txt";

my $odchr;
foreach my $k1(sort {$a <=> $b} keys %order){
	foreach my $k2(keys %{$order{$k1}}){
		my $key = $order{$k1}{$k2}{chr};
		if($icscaf{$k2} == 1){
			if($key ne $odchr){
				if($odchr){
					close OO;
				}
				$odchr = $key;
				open OO,">$chrout/$odchr.order";
			}
			print OO "$order{$k1}{$k2}{line}\n";
			print O1 "$order{$k1}{$k2}{line}\n";
			print O2 "$k2\t$all{$k2}\n";
			delete $map{$k2}; delete $all{$k2};
		}
	}
}
close IN;
close O1; close O2;

open O3,">$out/map_not_ordered.txt";
foreach(keys %map){
	print O3 "$_\t$all{$_}\n";
	delete $all{$_};
}
close O3;
open O4,">$out/unmap.txt";
foreach(keys %all){
	print O4 "$_\t$all{$_}\n";
}
close O4;


