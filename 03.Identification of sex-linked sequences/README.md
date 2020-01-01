**#1. Identification of Z-linked sequences:**

We identified the Z chromosome sequences out of the draft genomes based on their alignments to the Z chromosome sequences of ostrich(Zhang, et al. 2015; Yazdi and Ellegren 2018), and also a female-specific reduction of read depth.

Scaffold sequences of each species were aligned with LASTZ(Harris 2007) (version 1.02.00) to the ostrich Z chromosome sequence with parameter set ‘--step=19 --hspthresh=2200 --inner=2000 --ydrop=3400 --gappedthresh=10000 --format=axt’ and a score matrix set for distant species comparison. 

Alignments were converted into a series of syntenic ‘chains’, ‘net’ and ‘maf’ results with different levels of alignment scores using UCSC Genome Browser’s utilities (http://genomewiki.ucsc.edu/index.php/). 

  > perl lacnem.pl target.rm.fa query.rm.fa --parasuit chick  --qsub --direction lastZ.outdir  #step 1

Based on the whole genome alignments, we first identified the best aligned scaffolds within the overlapping regions on the reference genome, according to their alignment scores with a cutoff of at least 50% of the whole scaffold length aligned in the LASTZ net results. Scaffolds within the lower 5% region of each distribution were removed to avoid spurious alignments. 

  > sh chainning psudochromosomes/maf_chain_fa.sh lastZ.outdir Scam_Norn query.rm.fa psupseudoChr.outdir  #step 2
  
Finally, scaffolds were ordered and oriented into pseudo-chromosome sequences according to their unique positions on the reference. Scaffolds were linked with 600 ‘N’s as a mark of separation. 
  
  > cd psupseudoChr.outdir
  
  > grep chrZ scafOrderM_M.txt | awk '{print $2 "\t" $6 "\t" $7 "\t" "." "\t" "." "\t" "." "\t" $10 }'  > scafOrderM_M.chrZ.txt
  
  > perl fasta_artificial_chrZ.pl query.rm.fa scafOrderM_M.chrZ.txt > chrZ.rm.fa

  
**#2. Identification of W-linked sequences:**

W-linked sequences are expected to also form an alignment with the reference Z chromosome of ostrich, but with lower numbers of aligned sequences and lower levels of sequence identity than their homologous Z-linked sequences, due to the accumulation of deleterious mutations after recombination was suppressed on the W. 

   pick up W-linked candidates
  
  unmap.txt is the unmapping scaffolds/contigs produced at step 2
  > perl obtainFa.pl unmap.txt query.rm.fa  1 Positive > Scam_Norn.unmap.mask.fa

We also expect that there are still certain degrees (at least 70% as a cutoff) of sequence similarities between the Z- and W-linked sequences, for discriminating the true W-linked sequences from spurious alignments. After excluding the Z-linked sequences from the draft genome, we performed a second round of LASTZ alignment against the Z chromosome sequences of each species built from the above step. Then we excluded the spurious alignments with the cutoff of the pairwise sequence identity to be higher than 70%, but lower than 95%, and with the aligned sequences spanning at least 50% of the scaffold length. 

   perform lastZ alignment using w-linked candidates against chrZ.
   > repeat step 1, but replace "target.rm.fa" with chrZ.rm.fa, replace "query.rm.fa" with Scam_Norn.unmap.mask.fa

   deal lastZ alignment
  > cd 2round.lastZ.outdir/7.maf
  
  > perl dealW-linked/Maf2table.pl all.maf name .
  
  unmap.txt is the unmapping scaffolds/contigs produced at step 2
  > perl dealW-linked/Net2Order_v2.pl ../5.net/target.net unmap.txt name.maf.new.table name .
  
  unmap.txt is the unmapping scaffolds/contigs produced at step 2.
  depth.gz is output of samtools depth (see 02.BWA.alignment for details)
  > perl dealW-linked/depth_digger.pl depth.gz unmap.txt female
  
  all.maf unmap.txt.F.dp.gz is the output of depth_digger.pl
  > perl dealW-linked/IdentityScafZ.pl name.Synteny.table  all.maf unmap.txt.F.dp.gz |sort -k 2n > name.ide_dp.tab
  
  W-linked sequences
  > awk '$5 < 0.95' name.ide_dp.tab > name.ide_dp.tab.95

