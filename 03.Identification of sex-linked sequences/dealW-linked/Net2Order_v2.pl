#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

die "Usage: perl $0 net query_len maf_ordered_table prefix outdir\n$!" if(@ARGV <4);
my ($Block_Identity,$Block_Coverage,$Scaffold_Length,$Help);
GetOptions(
	'I:f'=>\$Block_Identity,
	'C:f'=>\$Block_Coverage,
	'L:i'=>\$Scaffold_Length,
	'h!'=>\$Help
);
$Block_Identity ||=0.7;
$Block_Coverage ||=0.5;
$Scaffold_Length ||=1000;

my $Net=shift;
my $Query_len=shift;
my $maf_table=shift;
my $prefix=shift;
my $Outdir=shift;

open OUT,">$Outdir/$prefix.Synteny.table";

my (%Net,%Query_len,%Maf,%RevNet);

Read_net($Net,\%Net);
#print Dumper(%Net);
Read_len($Query_len,\%Query_len);
Maf_table($maf_table,\%Maf);

for my $chr (keys %Net){
	my $count=0;
	foreach (@{$Net{$chr}}){
	if($Net{$chr}[$count][4]/$Query_len{$Net{$chr}[$count][2]} <=0.5){
		$count++;
		next;
	}
	else{
		my ($rt,$rp)=($Net{$chr}[$count][0],$Net{$chr}[$count][0]+$Net{$chr}[$count][1]);
		my $M=\@{$Maf{$Net{$chr}[$count][2]}};
		my $flag=0;
		my $total_aligned=0;
		my $r_total_aligned=0;

		my $matched_bases=0;
		foreach (@$M){
			if($M->[$flag][0] >=$rt && $M->[$flag][0] < $rp) {
				$total_aligned+=$M->[$flag][3];
				$r_total_aligned+=$M->[$flag][1];
				$matched_bases+=$M->[$flag][5];
#				print "$rt\t$rp\t$M->[$flag][0]\t$M->[$flag][1]\t$Net{$chr}[$count][2]\t$M->[$flag][2]\t$M->[$flag][3]\n";
			}
			$flag++;
		}
#		print "$rt\t$Net{$chr}[$count][1]\t$Net{$chr}[$count][2]\t$total_aligned\t$Query_len{$Net{$chr}[$count][2]}\n" if( $Query_len{$Net{$chr}[$count][2]} >=1000 );
		push @{$RevNet{$Net{$chr}[$count][2]}},[$Net{$chr}[$count][0],$Net{$chr}[$count][1],$Net{$chr}[$count][3],$Net{$chr}[$count][4],$Net{$chr}[$count][5],$Query_len{$Net{$chr}[$count][2]},$matched_bases,$Net{$chr}[$count][6]] if ( $Query_len{$Net{$chr}[$count][2]} >=$Scaffold_Length && $total_aligned/$Query_len{$Net{$chr}[$count][2]} >= $Block_Coverage && $matched_bases/$total_aligned >=$Block_Identity );
	}
	$count++;
}}

#print Dumper(%RevNet);
print OUT"#QueryID\tTstart\tT_net_block\tQstart\tQ_net_block\tchain_oirentation\tQlength\tmatched_bases\n";
for my $k (sort {$RevNet{$a}->[0][0] <=> $RevNet{$b}->[0][0]} keys %RevNet){
	my $count=1;
	my $tem=@{$RevNet{$k}};
	if($tem <=1){
		print OUT"$k\t$RevNet{$k}->[0][0]\t$RevNet{$k}->[0][1]\t$RevNet{$k}->[0][2]\t$RevNet{$k}->[0][3]\t$RevNet{$k}->[0][4]\t$RevNet{$k}->[0][5]\t$RevNet{$k}->[0][6]\n";
		next;
	}
	@{$RevNet{$k}}=sort {$b->[7]<=>$a->[7]} @{$RevNet{$k}};
	my $R=\@{$RevNet{$k}};
	my ($is,$ip)=($R->[0][2],$R->[0][2]+$R->[0][3]-1);
	my ($ris,$rip)=($R->[0][0],$R->[0][0]+$R->[0][1]-1);
	print OUT"$k\t$R->[0][0]\t$R->[0][1]\t$R->[0][2]\t$R->[0][3]\t$R->[0][4]\t$R->[0][5]\t$R->[0][6]\n";
	foreach (@$R){
		next if($tem ==$count);
		if($R->[$count][2]< $ip && $ip >= ($R->[$count][2]+$R->[$count][3]) ){
			if($is <=$R->[$count][2]){
				next;
				#print"$k\t$R->[$count][0]\t$R->[$count][1]\t$is\t$ip\t$R->[$count][4]\n";
			}
			else{
				my $sub_len=$is-$R->[$count][2]+1;
				if($sub_len >=1000){
					my ($Qtrunct_stop,$Rtrunct_stop)=($is-1,$R->[$count][0]+$sub_len-1);
					print OUT"$k\t$R->[$count][0]\t$sub_len\t$R->[$count][2]\t$sub_len\t$R->[$count][4]\n";
			}}		}
		elsif($R->[$count][2]< $ip && $ip <($R->[$count][2]+$R->[$count][3]-1) && ($R->[$count][2]+$R->[$count][3]-1) >$is){
			if($is <=$R->[$count][2] ){
				if(($R->[$count][2]+$R->[$count][3]-$ip)>=1000){
					my $sub_len=$is-$R->[$count][2]+1;
					my ($Qtrunct_start,$Rtrunct_start)=($ip+1,$R->[$count][0]+$R->[$count][1]-$sub_len);
					print OUT"$k\t$Rtrunct_start\t$sub_len\t$R->$Qtrunct_start\t$sub_len\t$R->[$count][4]\n";
			}}
			elsif($is > $R->[$count][2] && ($R->[$count][2]+$R->[$count][3]-$ip) >=1000){
				if($is-$R->[$count][2]+1 >=1000){
					my $sub_len1=$is-$R->[$count][2]+1;
					my $sub_len2=$R->[$count][2]+$R->[$count][3]-$ip;
					print OUT"$R->[$count][0]\t$sub_len1\t$R->[$count][2]\t$sub_len1\t$R->[$count][4]\n";
					my ($Qendst,$Rendst)=($ip+1,$R->[$count][0]+($ip-$R->[$count][2]+1));
					print OUT"$Rendst\t$sub_len2\t$Qendst\t$sub_len2\t$R->[$count][4]\n";
				}
				else{
					my $sub_len2=$R->[$count][2]+$R->[$count][3]-$ip;
					my ($Qendst,$Rendst)=($ip+1,$R->[$count][0]+($ip-$R->[$count][2]+1));
					print OUT"$Rendst\t$sub_len2\t$Qendst\t$sub_len2\t$R->[$count][4]\n";
				}
			}
			elsif($is > $R->[$count][2] && ($R->[$count][2]+$R->[$count][3]-$ip) <1000) {
				if($is-$R->[$count][2]+1 >=1000){
					my $sub_len2=$R->[$count][2]+$R->[$count][3]-$ip;
					my ($Qendst,$Rendst)=($ip+1,$R->[$count][0]+($ip-$R->[$count][2]+1));
					print OUT"$Rendst\t$sub_len2\t$Qendst\t$sub_len2\t$R->[$count][4]\n";
		}}}
		$count++;
}}

close OUT;

sub Read_net{
	my $f=shift;
	my $h=shift;
	my ($chr,$len);
	open IN,$f;
	while(<IN>){
		if(/^net\s+(\S+)\s+(\S+)/){
			($chr,$len)=($1,$2);
		}
		elsif(/^\sfill\s+(\d+)\s+(\d+)\s+(\S+)\s+([\+-])\s+(\d+)\s+(\d+).*score\s+(\d+).*/){
			my ($start,$len1,$chr2,$orientation,$start2,$len2,$score)=($1,$2,$3,$4,$5,$6,$7);
			push @{$h->{$chr}},[$start,$len1,$chr2,$start2,$len2,$orientation,$score];
		}}
	close IN;
}

sub Read_len{
	my $f=shift;
	my $h=shift;
	open IN,$f;
	while(<IN>){
		chomp;
		my ($id,$len)=($1,$2) if(/(\S+)\s+(\S+)/);
		$h->{$id}=$len;
	}
	close IN;
}

sub Maf_table{
	my $m=shift;
	my $h=shift;
	open IN,$m;
	while(<IN>){
		chomp;
		my @t=split"\t";
		push @{$h->{$t[5]}},[$t[1],$t[2],$t[6],$t[7],$t[8],$t[10],$t[9]];
	}
	close IN;
}
