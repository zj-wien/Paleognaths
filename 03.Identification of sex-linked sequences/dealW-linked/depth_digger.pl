#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use PerlIO::gzip;

die"usage: perl $0 depth.gz seq.lst sex\n$!" if(@ARGV <3);
my $depth=shift;
my $list=shift;
my $sex=shift;
my %list;
Tabreader($list,\%list);
open OUT,">:gzip","$list.$sex.dp.gz";
open DP,"<:gzip",$depth;
while(<DP>){
chomp;
my $bak=$_;
my @t=split"\t";
print OUT "$bak\n" if(exists $list{$t[0]});
}

sub Tabreader{
my $f=shift;
my $h=shift;
open IN,$f;
while(<IN>){
chomp;
next if(/^#/);
my $name=$1 if(/^(\S+)/);
$h->{$name}=$name;
}
close IN;
}
