**Homology-based prediction
Please refer to https://github.com/gigascience/paper-zhang2014/tree/master/Gene_annotation





**denovo.sh**

fa='/ifs5/NGB_UN/USER/wangzj/PaleognathousBirds/01.assembly/Northocercus_nigracapillus/Nnig.fa'
maskfa='/ifs5/NGB_UN/USER/wangzj/PaleognathousBirds/01.assembly/Northocercus_nigracapillus/Nnig.mask.fa'
gffs='/ifs5/NGB_UN/USER/wangzj/PaleognathousBirds/04.gene/Northocercus_nigracapillus/gallus_gallus.best.pep.genblast.genewise.gff /ifs5/NGB_UN/USER/wangzj/PaleognathousBirds/04.gene/Northocercus_nigracapillus/homo_sapiens.best.pep.genblast.genewise.gff /ifs5/NGB_UN/USER/wangzj/PaleognathousBirds/04.gene/Northocercus_nigracapillus/taeniopygia_guttata.best.pep.genblast.genewise.gff'
bfa=`basename $fa`;
prefix='Nnig'

#################################################
fbin='/ifs5/NGB_UN/USER/wangzj/PaleognathousBirds/toolkit/denovo-predict'

#:<<A
mkdir sets
 echo "date
 perl $fbin/train/bin/train_set_protein/perfect_gene.pl  --sco 100  --start 1  --stop 1 $fa $gffs
 perl $fbin/train/bin/train_set_protein/trainset_uniq.pl $bfa.gff.nr.gff
 perl $fbin/train/bin/train_set_protein/trainset_random.pl $bfa.gff.nr.gff.uniq.gff 1000
 perl $fbin/commen_bin/gff_statistic.pl $bfa.gff.nr.gff.uniq.gff.random.gff
 date"> sets/getsets.sh
#A

gff2train="$PWD/sets/$bfa.gff.nr.gff.uniq.gff.random.gff";# or you train set gff;
#################################################

mkdir augustus
echo "date
export PATH=$PATH:/ifs5/NGB_UN/USER/wangzj/PaleognathousBirds/toolkit/augustus-3.2.1/bin/
export AUGUSTUS_CONFIG_PATH=/ifs5/NGB_UN/USER/wangzj/PaleognathousBirds/toolkit/augustus-3.2.1/config/
perl $fbin/../augustus-3.2.1/scripts/autoAugTrain.pl --genome=$maskfa --trainingset=$gff2train  --species=$prefix  2>log
date " >augustus/augustus.train.sh
echo "nohup perl  $fbin/00.AUGUSTUS/bin/denovo-predict.pl --augustus $prefix  --cpu 10 $maskfa & " >augustus/augustus.run.sh
