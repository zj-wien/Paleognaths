#!/usr/bin/perl -w
use strict;
die "<fa.length> <samtool.depth>\n" unless @ARGV==2;

my %len;
open IN,"$ARGV[0]" or die $!;
while(<IN>){
	chomp;
	my @A=split /\t/;
	$len{$A[0]}=$A[1];
}
close IN;

my %mappedScaf;

my $scaf;
if($ARGV[1]=~/\.gz$/){
	open IN, "gunzip -c $ARGV[1] |" or die $!;
}else{
	open IN, "$ARGV[1]" or die $!;
}
my $offset=1;
while(<IN>){
	chomp;
	my @A=split /\t/;
	if(!$scaf){
		$scaf=$A[0];
		$mappedScaf{$scaf}=1;
		if($offset<$A[1]){
			for($offset=1;$offset<$A[1];$offset++){
				if($offset==1){
					print ">$scaf\n0";
				}else{
					print " 0";
				}
			}
			print " $A[2]";
			$offset++;
		}else{
			print ">$scaf\n$A[2]";
			$offset++;
		}
	}elsif($scaf ne $A[0]){
		if($offset<=$len{$scaf}){
			for(my $i=$offset;$i<=$len{$scaf};$i++){
				print " 0";
			}
		}
		$scaf=$A[0];
		$mappedScaf{$scaf}=1;
		$offset=1;
		if($offset<$A[1]){
			for($offset=1;$offset<$A[1];$offset++){
				if($offset==1){
					print "\n>$scaf\n0";
				}else{
					print " 0";
				}
			}
			print " $A[2]";
			$offset++;
		}else{
			print "\n>$scaf\n$A[2]";
			$offset++;
		}
	}else{
		if($offset<$A[1]){
			for(my $i=$offset;$i<$A[1];$i++){
				print " 0";
			}
			print " $A[2]";
			$offset=$A[1]+1;
		}elsif($offset==$A[1]){
			print " $A[2]";
			$offset++;
		}else{
			die;
		}
	}
}

if($offset<=$len{$scaf}){
	for(my $i=$offset;$i<=$len{$scaf};$i++){
		print " 0";
	}
}

print "\n";
close IN;

foreach my $key (keys %len){
	if(!exists $mappedScaf{$key}){
		print ">$key\n0";
		for(my $i=1;$i<$len{$key};$i++){
			print " 0";
		}
		print "\n";
	}
}


