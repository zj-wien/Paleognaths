#!/usr/bin/perl 
#===========================================================================
#         FILE:  chainScaf.pl
#===========================================================================
use strict;
use File::Basename qw(basename);
use FindBin qw($Bin);
use lib "$Bin";

die "
Usage : perl $0 <scaf.fa> <order.list> <outdir> <species name>\n
" if(@ARGV != 4);
my $NN = 600;
my $inN = "N";
$inN x= $NN;

my $scafile = shift;
my $orderfile = shift; # scafOrderM_M.txt
my $outdir = shift;
my $name = shift;
`mkdir -p $outdir` unless(-d $outdir);
my %scaf;
read_fasta($scafile,\%scaf);
open LEN,">$outdir/scaf.len";
foreach(keys %scaf){
	print LEN "$_\t$scaf{$_}{len}\n";
}
close LEN;
my %hash = (
    'A'=>'T','C'=>'G','G'=>'C','T'=>'A','N'=>'N',
    'a'=>'t','c'=>'g','g'=>'c','t'=>'a','n'=>'n'
);

my ($chr);
my ($start,$end,$flag) = (1, 1, 0);
open O1,">$outdir/$name.chain.fa";
open O2,">$outdir/$name.chain.list";
open IN,$orderfile;
while(<IN>){
	chomp;split;
	if(!$chr){
		$chr = $_[1];
		print O1 ">$chr\n";
	}
	my $seq = $scaf{$_[5]}{seq};
	if($_[6] eq "-"){
		$seq = subst($seq);
	}
	if($_[1] ne $chr || $_[1] != $chr){
		($start,$end,$flag) = (1,1,0);
		print O1 "\n";
		$chr = $_[1];
		print O1 ">$chr\n";

	}
	if($flag == 0){
		if($_[6] eq "-"){
			print O1 @{$seq};
		}else{
			print O1 $seq;
		}
		$flag = 1;
	}else{
		if($_[6] eq "-"){
			print O1 $inN,@{$seq};
		}else{
			print O1 $inN,$seq;
		}
	}
	$end = $start + $scaf{$_[5]}{len} - 1;
	print O2 "$chr\t$_[5]\t$start\t$end\n";
	$start = $end + $NN + 1;
#	}
}
close IN; close O1; close O2;

sub subst{
	my $str = shift;
	my @s = split(//,$str);
	my @new;
	my $i;
	for($i = 0; $i < @s-3 ; $i+=3){
		$new[$#s-$i] = $hash{$s[$i]};
		$new[$#s-$i-1] = $hash{$s[$i+1]};
		$new[$#s-$i-2] = $hash{$s[$i+2]};
	}
	while($i < @s){
		$new[$#s-$i] = $hash{$s[$i]};
		$i++;
	}
	return \@new;
}

sub read_fasta{
    my $file=shift;
    my $hash_p=shift;
    my $total_num;
    open (IN,$file) || die ("fail open $file\n");
    $/=">";<IN>;$/="\n";
    while(<IN>){
	chomp;
	my $head = $_;
	my $name=$1 if($head =~ /^(\S+)/);
	$/=">";
	my $seq=<IN>;
	chomp $seq;
	$seq=~s/\s+//g;
	$/="\n";
	warn "name $name is not uniq" if(exists $hash_p->{$name});
	$hash_p->{$name}{head} = $head;
	$hash_p->{$name}{len} = length($seq);
	$hash_p->{$name}{seq} = $seq;
	$total_num++;
	}
	close IN;
	return $total_num;
}
