#The scripts to process the non-coding tree
#1 prepare MAF into per chromosome
for i in `cat species.list`; do mafSplit -byTarget splits.bed ${i}/ ${i}/STRCA.${i}.rbest.maf.gz; cd ${i}/; for j in `ls *.maf |sed 's/.maf//'  `; do MBASE=`grep STRCA ${j}.maf |awk '{print $2 }' |uniq | sed 's/STRCA.//' `; mv ${j}.maf $MBASE.maf ; done; cd ../ ; done;

# 2 run  multiZ
python run_multiz.py --pair_align pair_alignment.list --multiple --chr_list CHRNAME.list --tree "((STRCA (Rame (Aman ((Dnov Ccas) (((NJul Nnig) (Tgut (Cund (Ccin Csou)))) (Eele (Nper (Norn Npen))))))) (Ggal TaeGut)) AllMis)" --out output3

#3 filter all the MAF/chr in folder output3, will generate *.filter files, pleae run each chromosome separately
for i in `cat CHRNAME.list`; do echo "perl filter_alignment_maf_v1.1B.pl --input output3/${i}/${i}.maf --window 36 --minidentity 0.55" >> runFilter.sh; done;

#4 prepare the coding GFF
for i in `cat CHR.list `; do awk -v var=$i '$1==var ' ostrich.cds.gff > GFF_${i}.gff; done;

# 5 sort the order of mafs in order to use Phast tools
for i in *.filter; do maf_order $i STRCA AllMis Aman Ccas Ccin Csou Cund Dnov Eele Ggal NJul Nnig Norn Npen Nper Rame TaeGut Tgut [all] > $i.srt; done;

#6 mask the coding regions with N
for i in `cat CHR.list`; do maf_parse -o  MAF -g GFF_${i}.gff --mask-features STRCA $i.filter.srt > $i.filter.srt.mask; done;

#7 run MAFFT to improve the local alignmentcut.filter1.pl
for i in *.cut; do ls $i/* |wc -l >> number_file.txt; done;
for i in *.cut; do echo $i  >> number_file.txt.name; done;
paste number_file.txt.name number_file.txt |awk '{OFS="\t"; print $1,$2}' |sed 's/.filter.feat.cut//' > number_file.final.txt
for i in `cat CHR.list`; do perl cut.filter1.pl ${i}.filter.srt.mask; done;
for i in `cat CHR.list`; do for file in `ls ${i}.filter.srt.mask.cut/*`; do echo "perl maf.to.mafft.pl $file &>> $file-logmafft" >> runMAFFT.sh; done; done;

#8 concatenate the mafft resultfor i in *.cut; do ls $i/* |wc -l >> number_file.txt; done;
awk '{print "for i in {1.."$2"}; do cat "$1".filter.srt.mask.cut/"$1".filter.srt.mask.cut.$i.mafft >> "$1".all.mafft;done;" }' number_file.final.txt >> concatenateMAFFT.sh

#9 remove columns where ref species is N (masked region)
perl remove_ns.pl noncoding.mega.mafft
#10 change to phylip
perl Fasta2Phylip.pl noncoding.mega.mafft.Nmask noncoding.mega.mafft.Nmask.phy
