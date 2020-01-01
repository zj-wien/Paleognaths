#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $filter2 = shift;
my $mafft = "mafft-linsi";

open IN,"$filter2";
$/="\n\n";
open MAFFT,">>$filter2.mafft";
while (<IN>)
{
    chomp;
    open OUT,">$filter2.temp";
# 	open OUT,">>$filter2.temp";
	my @lines = split /\n/;
    my $spe_number;
    foreach my $l (@lines)
    {
        next if ($l =~ /^#/ || $l =~ /score/);
        $spe_number ++;
    }
    next if ($spe_number < 11);
    
    foreach my $l (@lines)
    {
        next if ($l =~ /^#/ || $l =~ /score/);
        my @a = split /\s+/,$l;
        $a[-1]=~s/-//g;
        $a[-1]=~s/n//g;
        $a[-1]=~s/[atcg]//g;
        my $spe = $1 if ($a[1]=~/(\S+?)\./);
        print OUT ">$spe\n$a[-1]\n";
    }
    close OUT;
	
    system "$mafft --maxiterate 1000 --localpair $filter2.temp > $filter2.temp.mafft ";
    open IN2,"$filter2.temp.mafft";
    while (<IN2>)
    {
        print MAFFT "$_\n";
    }
    close IN2;
}
close MAFFT;
