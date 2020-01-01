**This page shows how we perform BWA alignment**
1. perfrom alignment with BWA-MEM algorithm
  
  >bwa mem -M -t 4 genome.fa reads.1.fq.gz reads.2.fq.gz | samtools view -hbS -@ 4 - | samtools sort -@ 4 -o file.bwa.bam
  
2. remove PCR duplicates/sort/compute the depth

  >samtools rmdup -S file.bwa.bam file.bwa.bam.withoutD.bam
  
  >samtools sort -@ 4 file.bwa.bam.withoutD.bam -o file.bwa.bam.withoutD.sort.bam
  
  >samtools depth -Q 30 file.bwa.bam.withoutD.sort.bam| gzip > file.bwa.bam.withoutD.sort.bam.depth.gz
  
3. format the output of "samtools depth" and produce depth for all positions along each scaffold.
  
    additional input file: genome.fa.len
      
    The file format is tab delimited, first column is chromosome name and second is its length.
        
  >perl samtoolDetph2soapcoverageSingleDepth.pl genome.fa.len file.bwa.bam.withoutD.sort.bam.depth.gz > file.bwa.bam.withoutD.sort.bam.depth.along.gz
 
 4. calculate frequency of depth 
  
  >perl depthsingle_distribution.pl file.bwa.bam.withoutD.sort.bam.depth.along.gz > file.bwa.bam.withoutD.sort.bam.depth.along.frequency
  
  
