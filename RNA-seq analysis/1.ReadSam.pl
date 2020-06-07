#!/usr/bin/perl -w
#zhangpei@genomics.cn
use strict;
use lib '/public/home/lijing/lib/perl5';
use Overlap;
use FindBin qw($Bin $Script);
if($#ARGV <4){die "perl $0 gff bam ratio readslength readnum\n"}
open IN,"$ARGV[0]";
my$ratio=$ARGV[2];
my$bam=$ARGV[1];
my$rL=$ARGV[3];
my$pwd=`pwd`;
chomp$pwd;
open OUT,">$ARGV[4]";
my$Unique;
my$StrandSpecific;
if($ARGV[5]){
	for(my$i=5;$i<=$#ARGV;$i++){
		if($ARGV[$i] eq 'Unique'){$Unique++}
		if($ARGV[$i] eq "StrandSpecific"){$StrandSpecific++}
	}
}
if(-e "$pwd/temp.gff"){system "rm $pwd/temp.gff"}
my%gff;
&parseGff($ARGV[0],\%gff);
foreach my$chr(keys %gff){
	foreach my$gene(keys %{$gff{$chr}}){
		my@exon;
		my$GeneLength;
		my$strand=$gff{$chr}{$gene}{strand}[0];
		my@start=sort{$a<=>$b}@{$gff{$chr}{$gene}{start}};
		my@end=sort{$a<=>$b}@{$gff{$chr}{$gene}{end}};
		my$ReadNum=0;
		foreach my$i(0..$#start){
			$GeneLength += $end[$i]-$start[$i]+1;
		}
		system "/usr/local/bin/samtools view $ARGV[1] $chr:$start[0]-$end[-1]>temp.sam";
		open IN,"temp.sam";
		while(<IN>){
			chomp;
			my@A=split(/\t/);
			if($Unique){
				my$tag=0;
				foreach my$ele(@A){
					if($ele eq 'NH:i:1' || $ele eq 'XT:A:U'){$tag=1}
				}
				if($tag == 0){next}
			}
			if($StrandSpecific){
				my$REVERSE=$A[1] & 16;
				my$FQ=$A[1] & 128;
				my$tag=0;
				if($strand eq '+'){
					if($REVERSE == 16 && $FQ == 0){$tag++}
					if($REVERSE == 0 && $FQ == 128){$tag++}
				}else{
					if($REVERSE ==16 && $FQ == 128){$tag++}
					if($REVERSE ==0 && $FQ == 0){$tag++}
				}
				if($tag==0){next}
			}
			my@SubLen=$A[5]=~/(\d+)/g;
			my@SubType=$A[5]=~/([A-Z-])/g;
			my$start=$A[3];
			my$end;
			my$CovLength=0;
			my$OverlapLen=0;
			my$k=0;
			for(my$j=0;$j<=$#SubLen;$j++){	
				if($SubType[$j] eq "S"){
					$start+=$SubLen[$j]
				}
				if($SubType[$j] eq "N"){
					$start += $SubLen[$j];
				}
				if($SubType[$j] eq "D"){
					$start += $SubLen[$j];
				}
				if($SubType[$j] eq "M"){
					$end=$start+$SubLen[$j]-1;
					foreach my$i($k..$#start){
						my@over=overlap($start, $end, $start[$i], $end[$i]);
						$OverlapLen+=$over[0];
						if($end[$i] < $end){
							$k=$i;
						}
						if($start[$i] > $end){
							last;
						}
					}
					$start+=$SubLen[$j];
				}
			}
			my$ratio2=$OverlapLen/$rL;
			if($ratio2>$ratio){
				$ReadNum++;
#				print "$gene\t$_\n";
			}
		}
		print OUT "$gene\t$ReadNum\t$GeneLength\n";
	}
}
sub parseGff{
	my$file=shift;
	my$hash=shift;
	open IN,"$file";            
	while(<IN>){                      
		chomp;                                      
		my($chr,$tag,$start,$end,$strand,$id)=(split /\s+/)[0,2,3,4,6,8];
		if($tag ne 'CDS'){next}                                                     
		if($id=~/Parent=(.+?);/){$id=$1}
#		if($id =~ /Parent/){die "$_\n"}
		push @{$$hash{$chr}{$id}{start}},$start;
		push @{$$hash{$chr}{$id}{end}},$end;                            
		push @{$$hash{$chr}{$id}{strand}},$strand;                                   
	}                       
	close IN;
}

