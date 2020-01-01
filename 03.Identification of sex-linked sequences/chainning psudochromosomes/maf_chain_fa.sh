#!/bin/bash - 
#================================================================
#          FILE: maf_chain_fa.sh
#   DESCRIPTION: chainning psudochromosomes according to lastz 
#                output
#================================================================

if [ $# -ne 4 ];then
	echo -e "\n\tUsage : sh $0 <lastz dir> <name> <query.fa> <outdir>\n"
	exit
fi

echo "--- Start Time : `date` ---"
lzdir=$1
name=$2
scafa=$3
out=$4


bin=`pwd`

outshell=$out

if [ ! -d $outshell ];then
	mkdir -p $outshell
fi
nMshell=$outshell/netMafa.sh
rm -rf $nMshell

lenlst=$lzdir/query.sizes
qnet=$lzdir/5.net/query.net
tnet=$lzdir/5.net/target.net
maf=$lzdir/7.maf/all.maf
outd=$out
Mo=$outd/scafOrderM.txt
Mv1=$outd/scafOrderM_v1.txt
idinfo=$outd/$name.identity.info
mafN50=$outd/scafMap.N50
MM=$outd/scafOrderM_M.txt
unudlen=$outd/unused.txt
chainfa=$outd/$name.chain.fa
chainlst=$outd/$name.chain.list
unfa=$outd/$name.chain.UM.fa
unlst=$outd/$name.chain.UM.list
psudofa=$outd/$name.psudo.fa
psudolst=$outd/$name.psudo.lst

if [ ! -d $outd ];then
	mkdir -p $outd
fi
echo "date
perl $bin/mafIAr.pl $maf $name $outd" >>$nMshell
echo "perl $bin/sub/qtnet.pl $qnet $tnet $outd" >>$nMshell
echo "perl $bin/sub/qtnetM.pl $outd/scafOrder.txt >$Mo" >>$nMshell
echo "perl $bin/sub/mafN50.pl $outd/scafMap.stat $idinfo >$mafN50" >>$nMshell
echo "perl $bin/sub/msort.pl $mafN50 $Mo" >>$nMshell
echo "perl $bin/sub/finalOrder.pl $lenlst $outd/$name.maf_IC.txt $idinfo $Mo.m.r $outd" >>$nMshell
echo "cat $outd/map_not_ordered.txt $outd/unmap.txt >$unudlen" >>$nMshell
echo "perl $bin/sub/chainScaf.pl $scafa $MM $outd $name" >>$nMshell
echo "perl $bin/sub/chainScafUM.pl $scafa $unudlen $out $name" >>$nMshell
echo "cat $chainfa $umfa >$psudofa" >>$nMshell
echo "cat $chainlst $umlst >$psudolst
date" >>$nMshell

echo "--- End Time : `date` ---"


