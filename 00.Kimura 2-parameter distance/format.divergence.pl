#!/usr/bin/perl -w
use strict;
use File::Basename;
die "Usage: perl $0 <file> <candidate.repeat.list>\n" unless @ARGV == 2;

my (%hash,%type,%species);
open (IN,$ARGV[1]) or die $!;
while (<IN>) {
	chomp;
	my @info = split /\t/;
	$type{$info[0]} = "C$info[1]";
}
close IN;

if ($ARGV[0] =~ /\.gz$/) {
	open (IN,"zcat $ARGV[0]|") or die $!;
} else {
	open (IN,$ARGV[0]) or die $!;
}
while (<IN>) {
	chomp;
	my @info = split /\t/;
	next if ($info[0] eq "species");
	my $div = int($info[7]);
	$hash{$info[0]}{$info[6]}{$div} += $info[4];
	$species{$info[0]} = $info[8];
}
close IN;

print "species\ttype\tdivergence\tpercent\n";
foreach my $spe (sort keys %hash) {
	foreach my $type (sort keys %{$hash{$spe}}) {
		next unless (exists $type{$type});
		foreach my $div (sort keys %{$hash{$spe}{$type}}) {
			my $percent = $hash{$spe}{$type}{$div}/$species{$spe}*100;
			my $line = join "\t",$spe,$type{$type},$div,$percent;
			#my $line = join "\t",$spe,$type,$div,$percent;
			print "$line\n";
		}
	}
}
