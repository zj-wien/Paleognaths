#!/usr/bin/perl
#==========================================================================
#         FILE:  qnet.pl
#==========================================================================

use strict;

my $qnet = shift;
my $tnet = shift;
my $out = shift;

`mkdir -p $out` unless (-d $out);
my %map;
my ($cutoff,$cutspan,$flag,$scafLen,$span) = (1000,0.5,0,0,0);
my ($scaf,$chr,%max,%qinfo);
open OUT,">$out/scafMap.stat";
open UM,">$out/scafUnMap.stat";
open IN,$qnet;
while(<IN>){
	chomp;split /\s+/,$_;
	if(/^net/){
		$flag = 0;
		if($_[2] < $cutoff){
			$flag = 1; next;
		}
		if($scafLen > 0){
			foreach (keys %max){
				my $v = $max{$_};
				if ($v > $span){
					$chr = $_; $span = $v;
				}
			}
			undef %max;
			my $ratio = $span/$scafLen;
			if($ratio > $cutspan){
				$map{$scaf}{chr} = $chr;
				$map{$scaf}{len} = $scafLen;
				print OUT "$scaf\t$scafLen\t$span\t",$ratio,"\t$chr\n";
			}else{
				print UM "$scaf\t$scafLen\t$span\t",$ratio,"\t$chr\n";
			}
		}
		$scafLen = $_[2]; $scaf = $_[1]; $span = 0;
	}
	if(/^\sfill/ && $flag == 0){
		$max{$_[4]} += $_[3];
		push @{$qinfo{$scaf}{$_[4]}},$_;
	}
}
close IN;
# last one
$span = 0;
foreach(keys %max){
	my $v = $max{$_};
	if($v > $span){
		$chr = $_; $span = $v;
	}
}
if($span/$scafLen > $cutspan){
	$map{$scaf}{chr} = $chr;
	$map{$scaf}{len} = $scafLen;
	print OUT "$scaf\t$scafLen\t$span\t",$span/$scafLen,"\t$chr\n";
}else{
	print UM "$scaf\t$scafLen\t$span\t",$span/$scafLen,"\t$chr\n";
}
close OUT; close UM;

my ($tchr,$tlen,@key,%tspan,%has,@info);
my (%tlength,%qhas); # 2/14/2012 %tlength for the rest scaffolds later
my $N = 0;
open OUT,">$out/scafOrder.txt";
print OUT "#1:row\t2:target\t3:t.len\t4:t.start\t5:t.size\t6:query\t7:strand\t8:q.start\t9:q.size\t10:q.len\t11.median\n";
open IN,$tnet;
while(<IN>){
	chomp;split /\s+/,$_;
	if(/^net/){
		$tlength{$_[1]} = $_[2];
		if($tchr){
			foreach my $k(keys %tspan){
				my $qlen = $map{$k}{len};
				if($tspan{$k}/$qlen < $cutspan){
					delete $tspan{$k};
				}
			}
			for(my $i = 0; $i < @info; ++$i){
				my @s = split /\t/,$info[$i];
				if($tspan{$s[2]}){
					my $median = $s[0] + $s[1]/2;
					$qhas{$s[2]} = 1;
					print OUT "$N\t$tchr\t$tlen\t$info[$i]\t$map{$s[2]}{len}\t$median\n";
					$N++;
				}
			}
			undef @info;
		}
		undef %tspan;
		$tchr = $_[1]; $tlen = $_[2];
		next;
	}
	if(/^\sfill/){
		if($map{$_[4]}{chr} eq $tchr){
			#           chr    tlen  scaf      scafLen       strand  start   len   start  len
			#print OUT "$tchr\t$tlen\t$_[4]\t$map{$_[4]}{len}\t$_[5]\t$_[2]\t$_[3]\t$_[6]\t$_[7]\n";
			my $info = $_;
			$info =~ s/^\s+fill\s+//g;
			$info =~ s/\s+id\s+.*//g;
			$info =~ s/\s+/\t/g;
			push @info,$info;
			$tspan{$_[4]} += $_[7];
			if(!$has{$_[4]}){
				push @key,$_[4];
				$has{$_[4]} = 1;
			}
		}
		next;
	}
}
close IN;
foreach my $k(keys %tspan){
	my $qlen = $map{$k}{len};
	if($tspan{$k}/$qlen < $cutspan){
		delete $tspan{$k};
	}
}
for(my $i = 0; $i < @info; ++$i){
	my @s = split /\t/,$info[$i];
	if($tspan{$s[2]}){
		my $median = $s[0] + $s[1]/2;
		$qhas{$s[2]} = 1;
		print OUT "$N\t$tchr\t$tlen\t$info[$i]\t$map{$s[2]}{len}\t$median\n";
		$N++;
	}
}

foreach my $k(keys %map){
	if(!$qhas{$k}){
		foreach my $k2(keys %{$qinfo{$k}}){
			if($map{$k}{chr} eq $k2){
				my @io = @{$qinfo{$k}{$k2}};
				for(my $i = 0; $i < @io; ++$i){
					my @s = split /\s+/,$io[$i];
					my $median = $s[6] + $s[7]/2;
					print OUT "$N\t$k2\t$tlength{$k2}\t$s[6]\t$s[7]\t$k\t$s[5]\t$s[2]\t$s[3]\t$map{$k}{len}\t$median\n";
					$N++;
				}
			}
		}
	}
}
close OUT;

