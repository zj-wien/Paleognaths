Here we provide a pipeline to process the non-coding tree, which includes 10 steps listed as follows. Please refer "script record" file for details.
#1 Pairwise genome alignments (prepare MAF into per chromosome)
#2 run  multiZ
#3 filter all the MAF/chr in folder output3, will generate *.filter files, pleae run each chromosome separately
#4 prepare the coding GFF
#5 sort the order of mafs in order to use Phast tools
#6 mask the coding regions with N
#7 run MAFFT to improve the local alignmentcut.filter1.pl
#8 concatenate the mafft result
#9 remove columns where ref species is N (masked region)
#10 change to phylip


####  Table 1. Species used to construct pairwise genome alignment ###      
Latin name	Common name
Struthio camelus	Common ostrich
Rhea americana	Greater rhea
Casuarius casuarius	Southern cassowary
Dromaius novaehollandiae	Emu
Apteryx mantelli	Brown kiwi
Nothocercus julius	Tawny-breasted tinamou
Nothocercus nigrocapillus	Hooded tinamou
Tinamus guttatus	White-throated tinamou
Crypturellus soui	Little tinamou
Crypturellus cinnamomeus	Thicket tinamou
Crypturellus undulatus	Undulated tinamous
Nothoprocta pentlandii	Andean tinamou
Nothoprocta ornata	Ornate tinamou
Nothoprocta perdicaria	Chilean tinamou
Eudromia elegans	Elegant crested tinamou
Taeniopygia guttata	Zebra finch
Gallus gallus	Chicken
Alligator mississippiensis	American alligator
### END ###
