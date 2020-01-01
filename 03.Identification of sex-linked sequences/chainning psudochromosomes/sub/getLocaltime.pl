#!/usr/bin/perl

my $time = get_localtime();
print $time;

sub get_localtime{
	my ($sec,$min,$hour,$mday,$mon,$year) = (localtime)[0..5];
	($sec,$min,$hour,$mday,$mon,$year) = (
		sprintf("%02d", $sec),
		sprintf("%02d", $min),
		sprintf("%02d", $hour),
		sprintf("%02d", $mday),
		sprintf("%02d", $mon + 1),
		$year + 1900
	);
	$year =~ s/^\d\d//;
	return $year.$mon.$mday;
#	print "$year-$mon-$mday $hour:$min:$sec\n";
}
