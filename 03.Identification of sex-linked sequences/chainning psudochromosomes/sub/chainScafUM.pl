#!/usr/bin/perl 
#===========================================================================
#         FILE:  chainScaf.pl
#===========================================================================
use strict;

die "
Usage : perl $0 <scaf.fa> <order.list> <outdir> <species name>\n
" if(@ARGV != 4);
my $NN = 600;
my $inN = "N";
$inN x= $NN;

my $scafile = shift;
my $orderfile = shift;
my $outdir = shift;
my $name = shift;
`mkdir -p $outdir` unless(-d $outdir);
my %scaf;
read_fasta($scafile,\%scaf);

my $pchr = "chrUM";
my $chrsize = 52428800;  # 50M
my ($start,$end,$flag,$flow,$sum) = (1, 1, 0, 1, 0);
open O1,">$outdir/$name.chain.UM.fa";
open O2,">$outdir/$name.chain.UM.list";
my $chr = $pchr.$flow;
print O1 ">$chr\n";
open IN,$orderfile;
while(<IN>){
	chomp;split;
	if($sum >= $chrsize){
		$flow++;
		$chr = $pchr.$flow;
		print O1 "\n>$chr\n";
		($start,$end,$flag) = (1,1,0);
		$sum = 0; 
	}
	$sum += $_[1];
	if($flag == 0){
		print O1 $scaf{$_[0]}{seq};
		$flag = 1;
	}else{
		print O1 $inN,$scaf{$_[0]}{seq};
	}
	$end = $start + $scaf{$_[0]}{len} - 1;
	print O2 "$chr\t$_[0]\t$start\t$end\n";
	$start = $end + $NN + 1;
}
close IN; close O1; close O2;

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
