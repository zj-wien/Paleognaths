#!/usr/bin/perl
#==========================================================================
#         FILE:  mafIAr.pl
#==========================================================================

=head
This script was designed to translate maf file to table and calculate the query coverage on target and alignment identity in sliding windows.

Input:
maf file -> the lastz result

output:
f1.$name.coverage.info :
#chr	#total length	#current length	#current position	#coverage
chrZ_061609     81930037        86562   10000   0.7563
chrZ_061609     81930037        86562   20000   0
f2.$name.identity.info :
#1 row	#2-6 for target in maf	#7-11 for query in maf	#12 identity
0       chrZ_061609     0       356     +       81930037        scaffold214  1349     358     -       36899   0.935
1       chrZ_061609     727     427     +       81930037        scaffold214  2079     418     -       36899   0.817
f3.$name.identity_win.txt :(used to calculate identity cutoff)
0.7044
0.6996
0.6379
0.7507
0.5725
0.7374
0.6296
f4.$name.maf_IC.txt : (maf Identity Coverage txt)
#the same with file 2 and the last column is coverage
0       chrZ_061609     0       356     +       81930037        scaffold214  1349     358     -       36899   0.935	0.028
1       chrZ_061609     727     427     +       81930037        scaffold214  2079     418     -       36899   0.817	0.028

f5.$name.maf_MU.txt : (maf Map Unused txt)
#the same with file 4.

use strict;
=cut

die "Usage :\n\tperl $0 <maf> <name> <out> <win>\n\n" if(@ARGV < 3);
my ($maf,$name,$out,$win) = @ARGV;

`mkdir -p $out` unless(-d $out);
$win = 10000 if(!$win);
my $idenCut = 0.95;

my (%hash,$tseq,$qseq,$ttseq,$qtseq,$qtseqlen,@iden);
my (%scafCov,$tcov,$sumCov,$chr,$lastlen,$curlen,@cov);
my $covpos = $win;
my ($covstart,$covflag) = (0,0);
my $N = 0;
open O1,">$out/$name.coverage.info";
open O2,">$out/$name.identity.info";
open OO,">$out/$name.identity_win.txt";
open IN,$maf;
while(<IN>){
	next if /^#/;
	next if /^a\s/;
	chomp;	my @s = split /\s+/,$_;
	$s[1] =~ s/(target|query)\.*//g;
	if(/^s\s+target/){
		if(!$chr){ $chr = $s[1]; $lastlen = $s[5]; }
		$curlen = $covstart + $s[2];
		if($s[1] ne $chr){
			$chr = $s[1];
			$covstart = $lastlen;
			$lastlen += $s[5];
		}
		while($curlen > $covpos){
			my $overcov = 0;
			my $vv = $sumCov - $win;
			if($vv > 0){
				$overcov = $vv;
				$sumCov -= $vv;
			}
			my $cov = $sumCov/$win;
			push @cov,$cov;
			print O1 $chr,"\t$lastlen\t",$curlen,"\t$covpos\t",$cov,"\n";
			$sumCov = $overcov;
			$covpos += $win;
		}
		$hash{$N}{target} = join ("\t",@s[1..5]);
		$tseq = $s[6]; $ttseq .= $s[6];
		$tcov = $s[3]; $sumCov += $s[3];
	}
	if(/^s\s+query/){
		my $info =  join ("\t",@s[1..5]);
		$hash{$N}{query} = $info;
		$qseq = $s[6]; $qtseq .= $s[6];
		$scafCov{$s[1]}{mapped} += $tcov;  # coverage
		$scafCov{$s[1]}{len} = $s[5];
		$hash{$N}{scaf} = $s[1];
		my $len = length($qseq);
		$qtseqlen += $len;
		my $alignc = 0;
		my @tseqArr = split //,$tseq;
		my @qseqArr = split //,$qseq;
		for (my $i = 0; $i < $len; ++$i){
			if($tseqArr[$i] =~ /[ACGTacgt]/ && $tseqArr[$i] eq $qseqArr[$i]){
				$alignc++;
			}
		}
		my $identy = $alignc/$len;
		print O2 "$N\t$hash{$N}{target}\t$hash{$N}{query}\t$identy\n";
		$hash{$N}{iden} = $identy;
		if($qtseqlen >= $win){
			my @ttArr = split //,$ttseq;
			my @qtArr = split //,$qtseq;
			my $qttc = 0;
			for(my $i = 0; $i < $win; ++$i){
				if($ttArr[$i] =~ /[ACGTacgt]/ && $ttArr[$i] eq $qtArr[$i]){
					$qttc++;
				}
			}
			my $tiden = $qttc/$win;
			print OO $tiden,"\n";
			push @iden,$tiden;
			my $RL = $qtseqlen - $win;
			$ttseq = substr($ttseq,$win,$RL); $qtseq = substr($qtseq,$win,$RL);
			$qtseqlen -= $win;
		}
		$N++;
	}
}
close IN; close O1; close O2; close OO;


my $cutpos = @iden;
$cutpos *= 1-$idenCut;
@iden = sort {$a <=> $b} @iden;
my $cutVal = $iden[int($cutpos)];
print STDERR "Identity cutoff : $cutVal\n";
my $cutcov = @cov;
$cutcov *= 1-$idenCut;
@cov = sort {$a <=> $b} @cov;
my $covVal = $cov[int($cutcov)];
print STDERR "Coverage cutoff : $covVal\n";

open O3,">$out/$name.maf_IC.txt"; # maf Identity Coverage txt
open O4,">$out/$name.maf_MU.txt"; # maf Map Unused txt
foreach(sort {$a <=> $b} keys %hash){
	my $k = $hash{$_}{scaf};
	my $covv = $scafCov{$k}{mapped}/$scafCov{$k}{len};
	if($hash{$_}{iden} >= $cutVal && $covv >= $covVal){
		print O3 "$_\t$hash{$_}{target}\t$hash{$_}{query}\t$hash{$_}{iden}\t$covv\n";
	}else{
		print O4 "$_\t$hash{$_}{target}\t$hash{$_}{query}\t$hash{$_}{iden}\t$covv\n";
	}
}
close O3; close O4;
