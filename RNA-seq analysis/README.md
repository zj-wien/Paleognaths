**1. Align the rna-seq reads to the genome and sort bam file**

  >sh  alignment_hisat2_sort.sh

**2. Calculate expression level

  >perl 0.creat.sh.pl --BAM $i.bam --Gff Nothoprocta_perdicaria.gff  --ratio 0.5 --Split 5 --Res $i.rpkm --rL 75 --Unique
  
**3. RPKMs across tissues were adjusted by a scaling method based on TMM
  
  >perl library_normalization.pl lib.list geometric
  
  lib.list contains rpkm information, which include two columns for each tissue (per line):
    sample_name absolute_path_of_rpkm_file_from_step_2



