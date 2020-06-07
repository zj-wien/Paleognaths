** Calculate Ka/Ks using KaKs_Calculator

  shell Script: pepMfa_to_cdsMfa.pl 
  
  >for k in *pep
  >do
  >CDS=${k//pep/cds}
   
  >/apps/muscle/3.8.31/muscle -in $k -out $k.muscle
  
  >perl pepMfa_to_cdsMfa.pl $k.muscle $CDS > $CDS.muscle
  
  >sed -i '3d' $CDS.muscle
  
  >KaKs_Calculator -i $CDS.muscle -o $CDS.muscle.kaks
  
  >done
