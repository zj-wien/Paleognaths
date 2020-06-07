#!/usr/bin/perl -w
# zhangpei@genomics.cn
use strict;
use FindBin qw($Bin $Script);
use Getopt::Long;
GetOptions(
		'BAM=s'=>\our$bam,
		'Gff=s'=>\our$gff,
		'ratio=f'=>\our$ratio,
		'Split=i'=>\our$split,
		'Res=s'=>\our$result,
		'rL=i'=>\our$rL,
		'Unique'=>\our$Unique,
		'StrandSpecific'=>\our$StrandSpecific
		);
my$help=<<"HELP";
	--BAM	<str>	bam file
	--Gff	<str>	gff file
	--ratio	<float>	ratio of overlap, 0.5 default
	--Split	<int>	Split Gff
	--Res	<str>	result file
	--rL	<int>	reads length
	--Unique		only unique mapped reads used
	--StrandSpecific	Strand Specific library
HELP
my$pwd=`pwd`;
chomp$pwd;
if(!$bam || !$gff || !$result){die "$help"}
$ratio ||=0.5;
#$bam=$pwd.'/'.$bam;
my$Ngff=`cat $gff |grep "mRNA"|wc -l`;
#die "$Ngff\n";
chomp $Ngff;
$split=int($Ngff/$split)+1;
my$i=0;
open IN,"$gff";
while(<IN>){
	chomp;
	if($i % $split==0 && $_=~/mRNA/){
		my$j=int($i/$split);
		mkdir "part$j";
		open OUT,">part$j/part$j.gff";
	}
	print OUT "$_\n";
	if($_=~/mRNA/){$i++;}
}
close IN;
my@file=glob 'part*/';
open SH1,">step1.get.num.sh";
$pwd=`pwd`;
chomp($pwd);
foreach my$ele(@file){
	chop$ele;
	my$sh="perl $Bin/1.ReadSam.pl $pwd/$ele/$ele.gff $bam $ratio $rL $pwd/$ele/$ele.num";
	if($Unique){$sh=$sh." Unique"}
	if($StrandSpecific){$sh=$sh." StrandSpecific"}
	open OUT,">$ele/$ele.num.sh";
	print OUT "$sh\n";
	print OUT "echo done\n";
	close OUT;
	print SH1 "cd $ele; qsub -cwd -l vf=0.1g $ele.num.sh; cd ../\n";
}
close SH1;
open SH2,">step2.rpkm.sh";
print SH2 "perl $Bin/2.merge.pl $result\n";
close SH2;
