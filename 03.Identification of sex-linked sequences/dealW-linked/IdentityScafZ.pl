#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use PerlIO::gzip;
my $Syn=shift;
my $maf=shift;
my $dp=shift;

my (%Syn,%bases,%depth);
ReadSyn($Syn,\%Syn);
#print Dumper(%Syn);
DpCal($dp,\%depth);

open MAF,$maf;
while(<MAF>){
    chomp;
    next if(/^##.*/);
    my $line2=<MAF>;
    my $line3=<MAF>;
    my $line4=<MAF>;
    chomp $line2;
    chomp $line3;
    my @t=split" ", $line2;
    my @q=split" ", $line3;
    $t[1]=$1 if($t[1]=~/target\.(\S+)/);
    $q[1]=$1 if($q[1]=~/query\.(\S+)/);
    if(exists $Syn{$q[1]}){
	if($Syn{$q[1]}[0]<= $t[2] && $Syn{$q[1]}[0]+$Syn{$q[1]}[1]>$t[2]){
	    my $mbases=Iden_cal($t[6],$q[6]);
	    $bases{$q[1]}[0]+=$q[3];
	    $bases{$q[1]}[1]+=$mbases;
	}
    }
}
close MAF;
# print Dumper(%bases);
for my $k(keys %bases){
    #print" $bases{$k}[0]\t$bases{$k}[1]\t$Syn{$k}[4]\n";
    my $ide=$bases{$k}[1]/$bases{$k}[0];
    my $qstart=$Syn{$k}[0]+1-$Syn{$k}[2];
    next if(not exists $depth{$k});
    my $avg_dp=$depth{$k}[0]/$depth{$k}[1];
    print"$k\t$qstart\t$Syn{$k}[3]\t$avg_dp\t$ide\n";
}

sub ReadSyn{
    my $f=shift;
    my $h=shift;
    open IN,$f;
    while(<IN>){
	chomp;
	next if(/^#/);
	my @t=split"\t";
	$h->{$t[0]}=[$t[1],$t[2],$t[3],$t[6]];
	}
	close IN;
}

sub Iden_cal{
    my $seq1=shift;
    my $seq2=shift;
    my $match_bases=0;
    my $len= length $seq1;
    for(my $i=0; $i < $len; $i++){
	my $e1=substr($seq1,$i,1);
	my $e2=substr($seq2,$i,1);
	$match_bases+=1 if($e1 eq $e2);
	}
	return $match_bases;
}

sub DpCal{
    my $f=shift;
    my $h=shift;
    open DP,"<:gzip",$f;
    while(<DP>){
	chomp;
	my @t=split"\t";
	$h->{$t[0]}[0]+=$t[2];
	$h->{$t[0]}[1]+=1;
    }
    close DP;
}
