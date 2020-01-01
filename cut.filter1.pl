#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $filter1 = shift;
`mkdir $filter1.cut`;
open IN,"$filter1";
$/ = "\n\n";
my $i = 0;
my $j = 0;
while (<IN>)
{
    chomp;
    $i++;
    if ($i == 1)
    {
        $j++;
        open OUT, ">$filter1.cut/$filter1.cut.$j" or die "$j\n";
    }
    if ($i< 10000)
    {
        print OUT "$_\n\n";
    }
    if ($i == 10000)
    {
        print OUT "$_\n\n";
        close OUT;
        $i = 0;
    }
}
close IN;
