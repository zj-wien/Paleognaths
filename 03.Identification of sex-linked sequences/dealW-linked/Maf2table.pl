#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use File::Basename qw/dirname basename/;
die"Usage:perl $0 z_w.maf prefix outdir\n$!" if(@ARGV <3);

my $maf=shift;
my $prefix=shift;
my $Outdir=shift;

open OUT,">$Outdir/$prefix.maf.new.table";
open IN,$maf;
while(<IN>){
	chomp;
	next if (/^##.*/);
	my $line2=<IN>;
	chomp $line2;
	my $line3=<IN>;
	my @t=split" ",$line2;
	chomp $line3;
	my $line4=<IN>;
	my @q=split" ", $line3;
	$t[1]=$1 if($t[1]=~/target\.(\S+)/);
	$q[1]=$1 if($q[1]=~/query\.(\S+)/);

	my $mbases=Iden_cal($t[6],$q[6]);
	print OUT"$t[1]\t$t[2]\t$t[3]\t$t[4]\t$t[5]\t$q[1]\t$q[2]\t$q[3]\t$q[4]\t$q[5]\t$mbases\n";
}
close IN;


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
