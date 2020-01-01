#!/usr/bin/perl -w
use strict;
use File::Basename;
die "Usage: perl $0 <align.dir>  <len.dir>\n" unless @ARGV == 2;

my (%genome,@species);
my @files = `find $ARGV[0] -name "*.fa.align"`;
my @lens = `find  $ARGV[1] -name "*.fa.tbl"`;

my %la_co = (
		"Struthio_camelus"=> "Ostrich",
		"Apteryx_mantelli" => "Brown kiwi",
		"Casuarius_casuarius" => "Southern cassowary",
		"Dromaius_novaehollandiae" => "Emu",
		"Rhea_americana" => "Greater rhea",
		"Nothoprocta_ornate" => "Ornate tinamou",
		"Nothoprocta_pentlandii" => "Andean tinamou",
		"Nothoprocta_perdicaria" => "Chilean tinamou",
		"Eudromia_elegans" => "Elegant crested tinamou",
		"Nothocercus_Julius" => "Tawny-breasted Tinamou",
		"Northocercus_nigracapillus" => "Hooded tinamou",
		"Crypturellus_cinnamomeus"=> "Thicket tinamou",
		"Crypturellus_soui" => "Little tinamou",
		"Crypturellus_undulatus" => "Undulated tinamou",
		"Tinamus_guttatus" => "White-throated tinamou",
);

foreach my $len (@lens) {
	chomp $len;
	my $latin = (split /\./,basename($len))[0];
	next unless ($latin =~ /_/);
	countLen($len,$latin);
}
print "species\tscaffold\tstart\tend\tlength\tclass\tfamily\tkimura\tgenomesize\n";

foreach my $file (@files) {
	chomp $file;
	my $latin = (split /\./,basename($file))[0];
	push @species,$latin;
	dealRepeatMasker($file,$latin);
}

sub countLen {
	my ($file,$name) = @_;
	my $total;
	open (RE,$file);
	while (<RE>) {
		chomp;
		if (/^bases masked:/) {
			$total = (split /\s+/)[2];	#print STDERR "$name\t$total\n";
		}
	}
	close RE;
	$genome{$name} = $total;
}

sub dealRepeatMasker{
	my ($file,$name) = @_;
	
	open (RE, $file);
	#$/ = "Gap_init rate";
	$/ = "\n\n\n";
	while (<RE>) {
	    chomp;
		
		my @lines = split /\n/;
		my $kimura = 100;
		my ($scaf,$begin,$end,$length,$class,$family,$transI,$transV);
		foreach my $line (@lines) {
			next if (/^$/);
			# Kimura Divergence
			# - Non crossmatch field
			if ( $line =~ /^Kimura.*=\s*(\S+)/ ) {
			 	$kimura = $1;
			}
		
			# Look for transition/transversion ratio
			if ( $line =~ /Transitions.*\((\d+)\s*\/\s*(\d+)\)/ ) {
				$transI = $1;
				$transV = $2;
			}
		
			# Look for a header line (e.g.):
			if ( $line =~ /^\d+\s+\d+(\.\d+)?/ ) {
				my @hdrLineArray = (split /\s+/,$line);
				
				# A new *.align file or cat file ( id field unused )
				if ( $hdrLineArray[ 8 ] eq "C" ) {
					($family,$class) = (split /#/,$hdrLineArray[ 9 ])
				} else {
					($family,$class) = (split /#/,$hdrLineArray[ 8 ])
				}
				($scaf,$begin,$end) = @hdrLineArray[4,5,6];
				$length = $end - $begin + 1;
			}
		}
		
		my $line = join "\t",$la_co{$name},$scaf,$begin,$end,$length,$class,$family,$kimura,$genome{$name};
		print "$line\n";
	}
	close RE;
	$/ = "\n";
}
