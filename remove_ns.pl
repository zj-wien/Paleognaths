#!/usr/bin/perl -w
use strict;
use Data::Dumper;


my $mafft=shift;


my %pool=("Aman"=>"","Ccas"=>"", "Ccin"=>"","Csou"=>"", "Cund"=>"", "Dnov"=>"", "Eele"=>"", "NJul"=>"", "Nnig"=>"", "Norn"=>"","Npen"=>"", "Nper"=>"", "Rame"=>"", "STRCA"=>"", "Tgut"=>"","TaeGut"=>"","AllMis"=>"","Ggal"=>"");

open MAFFT,$mafft;
my $count=1;
$/="\n\n";
while(<MAFFT>){
	chomp;
	#next if($count >1);
	my @t= split ">";
	shift @t;
	my $f=0;
	my %tmp;
	my $len;
	my @ncor;
	foreach (@t){
	#next if($f >1);
		my ($id,$seq)=($1,$') if($t[$f]=~/^(\S+)/);
		$seq=~s/\s+//g;
		if($id eq "STRCA"){
			my $subs=$seq;
			my $lenrm=0;
			while( $subs=~/([n]+)/){
				my $pos=index($subs,$1);
				my $mask_len=length($1);
#				print $lenrm+$pos,"\t",$mask_len,"\n";
				push @ncor,[$lenrm+$pos,$mask_len];
				$lenrm+=($pos+length($1));
				$subs=substr($subs, $pos+(length $1));
			}
		}
		$f++;
		$tmp{$id}=$seq;
		$len=length $seq if($f==1);
	}
#	print Dumper(@ncor);
	for my $k(keys %pool){
		if(not exists $tmp{$k}){
		$pool{$k}.= "-"x$len ;
		}
		else{
		$pool{$k}.=&mask_site($tmp{$k},\@ncor) if(scalar @ncor > 0); #{print "$k\n";}		
		$pool{$k}.=$tmp{$k} if(scalar @ncor eq 0);
		}

	}
	$count++;
}
#close MAFFT;
open OUT,">$mafft.Nmask";
for my $k (sort {$a cmp $b } keys %pool){
print OUT ">$k\n$pool{$k}\n";
}


#
sub mask_site{
	my $s=shift;
	my $a=shift;
	foreach my $k (@$a){
#		print $k->[0],"\t",$k->[1],"\n";
		substr($s,$k->[0],$k->[1],"-"x$k->[1]);
	}
	return $s;
}
