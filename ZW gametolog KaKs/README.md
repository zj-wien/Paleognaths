**Calculate Ka/Ks using KaKs_Calculator**

  shell Script: pepMfa_to_cdsMfa.pl 
  
  >for k in *pep
  >do
  >CDS=${k//pep/cds}
   
  >/apps/muscle/3.8.31/muscle -in $k -out $k.muscle
  
  >perl pepMfa_to_cdsMfa.pl $k.muscle $CDS > $CDS.muscle
  
  >sed -i '3d' $CDS.muscle
  
  >KaKs_Calculator -i $CDS.muscle -o $CDS.muscle.kaks
  
  >done
  
pepMfa_to_cdsMfa.pl -- convert protein alignment to cds alignment



**Draw distribution of pairwise Ks values between Z/W gametologs along the Z chromosome of each studied species**

  Rscript  draw.Ks.all.species.point.R all.ks.2.txt.pdf all.ks.2.txt
  
  
**construct maximum likelihood trees by RAxML**

/apps/raxml/8.2.12/bin/raxmlHPC -o Scam.Z -f a -m GTRGAMMA -p 12345 -x 12345 -# 100 -s ../03.Scam.parse.muscle/real/Scam_Sca_R015800.pep.fa.muscle.cds.phy -n Scam_Sca_R015800


