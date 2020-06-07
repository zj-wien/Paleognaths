#!/usr/bin/perl -w
use strict;
if(!$ARGV[0]){die "perl $0 lib method [geometric,TMM,RLE,upperquartile]\n"}
my%file;
my@lib;
my%length;
open IN,"$ARGV[0]";
while(<IN>){
	chomp;
	my@A=split(/\s+/);
	$A[0]=~s/-/./g;
	$file{$A[0]}=$A[1];
	push @lib,$A[0];
}
close IN;
our%num;
our%totalnum;
foreach my$key(keys %file){
	open IN,"$file{$key}";
	while(<IN>){
		chomp;
		my@A=split(/\t/);
		$num{$A[0]}{$key}=$A[3];
		$totalnum{$key}+=$A[3];
		$length{$A[0]}=$A[4];
	}
	close IN;
}
our$cound;
open OUT, ">lib.toNorm.num";
print OUT "$lib[0]";
my@totalsize;
$cound="\"".$lib[0]."\"";
for(my$i=1;$i<=$#lib;$i++){
	print OUT "\t$lib[$i]";
	$cound=$cound.","."\"".$lib[$i]."\"";
	push @totalsize,$totalnum{$lib[$i]};
}
my$average_size=&avg(@totalsize);
print OUT "\n";
foreach my$key(keys %num){
	print OUT "$key";
	for(my$i=0;$i<=$#lib;$i++){
		if(!$num{$key} || !$num{$key}{$lib[$i]}){$num{$key}{$lib[$i]}=0}
		print OUT "\t$num{$key}{$lib[$i]}";
	}
	print OUT "\n";
}
close OUT;
our%norm;
if($ARGV[1] eq 'geometric'){
	&DESeq;
}elsif($ARGV[1] eq 'TMM'){
	&edgeR("TMM");
}elsif($ARGV[1] eq 'RLE'){
	&edgeR("RLE")
}elsif($ARGV[1] eq 'upperquartile'){
	&edgeR("upperquartile")
}elsif($ARGV[1] eq 'NULL'){
	foreach my$ele(@lib){
		$norm{$ele}=1;
	}
}
open OUT,">lib.toNorm_NormFactors.txt";
print OUT "Samples\tOrigReadNum\tNormFactor\tNormedReadsNum\n";
my%adjust_totalnum;
if($ARGV[1] eq 'geometric'){
	foreach my$ele(@lib){
		$adjust_totalnum{$ele}=int($average_size*$norm{$ele});
		my$norm_factor=$adjust_totalnum{$ele}/$totalnum{$ele};
		print OUT "$ele\t$totalnum{$ele}\t$norm_factor\t$adjust_totalnum{$ele}\n";
	}
}else{
	foreach my$ele(@lib){
		$adjust_totalnum{$ele}=int($totalnum{$ele}*$norm{$ele});
		print OUT "$ele\t$totalnum{$ele}\t$norm{$ele}\t$adjust_totalnum{$ele}\n";
	}
}
close OUT;
open OUT,">lib.toNorm.rpkm";
print OUT "Samples";
for(my$i=0;$i<=$#lib;$i++){
	print OUT "\t$lib[$i]";
}
print OUT "\n";
foreach my$key(keys %num){
	print OUT "$key";
	for(my$i=0;$i<=$#lib;$i++){
		my$rpkm=$num{$key}{$lib[$i]}*1000*1000000/$length{$key}/$adjust_totalnum{$lib[$i]};
		print OUT "\t$rpkm";
	}
	print OUT "\n";
}
close OUT;
sub edgeR{
	my$method="$_[0]";
	my$add;
	my$edger=<<"EDGER";
library( edgeR )
contsTab<-read.delim("lib.toNorm.num",row.names=1)
cound<-c($cound)
dgl<-DGEList(counts = contsTab, group = cound)
cpm.d<-cpm(dgl)
dgl<-dgl[rowSums(cpm.d > 1) >=3,]
dgl<-calcNormFactors(dgl,method="$method")
write.table(dgl\$sample,"norm.factors.txt",sep="\\t")
EDGER
	open OUT,">adjust.R";
	print OUT "$edger\n";
	close OUT;
	system "/usr/local/bin/R -f adjust.R";
	open IN,"norm.factors.txt";
	while(<IN>){
		chomp;
		my@A=split(/\t/);
		$A[0]=~s/"//g;
		$norm{$A[0]}=$A[3];
	}
	close IN;
	system "rm norm.factors.txt";
}
sub DESeq{
	my$deseq=<<"DESEQ";
library( DESeq )
contsTab<-read.delim("lib.toNorm.num",row.names=1)
cound<-c($cound)
cds<-newCountDataSet(contsTab,cound)
cds<-estimateSizeFactors(cds)
write.table(sizeFactors(cds),"norm.factors.txt",sep="\\t")
DESEQ
	open OUT,">adjust.R";
	print OUT "$deseq\n";
	close OUT;
	system "/usr/local/bin/R -f adjust.R";
	open IN,"norm.factors.txt";
	<IN>;
	while(<IN>){
		chomp;
		my@A=split(/\t/);
		$A[0]=~s/"//g;
		$norm{$A[0]}=$A[1];
	}
	close IN;
	system "rm norm.factors.txt";
}
sub avg{
	my$sum=0;
	my$num=0;
	foreach my$ele(@_){
		$sum+=log($ele)/log(2);
		$num++;
	}
	my$avg=$sum/$num;
	$avg=2**$avg;
	return($avg);
}
