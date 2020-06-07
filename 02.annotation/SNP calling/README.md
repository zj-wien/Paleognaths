**This page shows how we perform SNP calling **

1. BWA alignment
  >/share/app/bin/bwa index -a is Nothoprocta_perdicaria.fa
  
  >/share/app/bin/bwa mem -M -t 4 Nothoprocta_perdicaria.fa 160324_I631_FCC837CACXX_L2_CHKPEI85216020140/fq14/14.1.fq.gz 160324_I631_FCC837CACXX_L2_CHKPEI85216020140/fq14/14.2.fq.gz | /usr/local/bin/samtools view -hbS -@ 4 - | /usr/local/bin/samtools sort -@ 4 -o 160324_I631_FCC837CACXX_L2_CHKPEI85216020140/fq14/160324_I631_FCC837CACXX_L2_CHKPEI85216020140.bwa.bam
  
2. SNP calling
  >/usr/local/bin/samtools view -bS -t Nothoprocta_perdicaria.fa.fai Nothoprocta_perdicaria.merge.bam -o Nothoprocta_perdicaria.fai.bam
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx10G -jar /share/app/picard-tools-2.5.0/picard.jar ValidateSamFile I=Nothoprocta_perdicaria/Nothoprocta_perdicaria.fai.bam  O=Nothoprocta_perdicaria.fai.bam.validate MO=500000000
  
  >perl /public/home/wangzj/pipeline/GATK/bin/filter.pl Nothoprocta_perdicaria.fai.bam.validate Nothoprocta_perdicaria.fai.bam Nothoprocta_perdicaria.fai.filter.bam
  
  >/usr/local/bin/samtools view Nothoprocta_perdicaria.fai.filter.bam  -h  >Nothoprocta_perdicaria.fai.filter.sam
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx10G -jar /share/app/picard-tools-2.5.0/picard.jar CleanSam I=Nothoprocta_perdicaria.fai.filter.sam O=Nothoprocta_perdicaria.fai.filter.clean.sam
  
  >/usr/local/bin/samtools view -bS -t Nothoprocta_perdicaria.fa.fai Nothoprocta_perdicaria.fai.filter.clean.sam > Nothoprocta_perdicaria.fai.filter.clean.bam
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx100G -jar /share/app/picard-tools-2.5.0/picard.jar SortSam SORT_ORDER=coordinate TMP_DIR=Nothoprocta_perdicaria INPUT=Nothoprocta_perdicaria.fai.filter.clean.bam OUTPUT=Nothoprocta_perdicaria.fai.filter.clean.sorted.bam 1>sort.log 2>&1
  
  > /usr/local/jdk1.8.0_101/bin/java -Xmx100G -jar /share/app/picard-tools-2.5.0/picard.jar MarkDuplicates INPUT=Nothoprocta_perdicaria.fai.filter.clean.sorted.bam OUTPUT=Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.bam  METRICS_FILE=Nothoprocta_perdicaria.fai.filter.clean.sorted.bam.metrics ASSUME_SORTED=true TMP_DIR=tmp MAX_FILE_HANDLES=800  1>dedup.log 2>&1
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx100G -jar /share/app/picard-tools-2.5.0/picard.jar AddOrReplaceReadGroups I=Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.bam O=Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.bam LB=LB PL=illumina PU=PU SM=SM 1>addGroup.log 2>&1
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx100G -jar /share/app/picard-tools-2.5.0/picard.jar BuildBamIndex INPUT=Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.bam
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx100G -Djava.io.tmpdir=Nothoprocta_perdicaria  -jar /share/app/GATK/GenomeAnalysisTK.jar -T RealignerTargetCreator -R Nothoprocta_perdicaria.fa -I Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.bam -o Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.intervals 1>intervals.log 2>&1
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx100G -Djava.io.tmpdir=Nothoprocta_perdicaria  -jar /share/app/GATK/GenomeAnalysisTK.jar -T IndelRealigner -R Nothoprocta_perdicaria.fa -I Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.bam -targetIntervals Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.intervals -o Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.bam 1>realign.log 2>&1
  
  > /usr/local/jdk1.8.0_101/bin/java -Xmx100g -jar /share/app/GATK/GenomeAnalysisTK.jar  -T BaseRecalibrator -R Nothoprocta_perdicaria.fa --run_without_dbsnp_potentially_ruining_quality -I Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.bam  -o Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.grp 1>recal.log 2>&1
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx100G -Djava.io.tmpdir=Nothoprocta_perdicaria -jar /share/app/GATK/GenomeAnalysisTK.jar -T PrintReads  -R Nothoprocta_perdicaria.fa  -I Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.bam   -BQSR Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.grp -o Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam --num_bam_file_handles 100 1>printRead.log 2>&1
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx300G -Djava.io.tmpdir=Nothoprocta_perdicaria -jar /share/app/GATK/GenomeAnalysisTK.jar -T UnifiedGenotyper -R -glm SNP -I Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam  -o Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam.Q20.vcf  -stand_call_conf 30 -stand_emit_conf 30 -ploidy 2 -mbq 20  1>callSnp.log 2>&1
  
  >MEANQUAL=100
  >/usr/local/jdk1.8.0_101/bin/java -Xmx100G -jar /share/app/GATK/GenomeAnalysisTK.jar -T VariantFiltration -R Nothoprocta_perdicaria.fa --filterExpression " DP < 10 || QUAL < $MEANQUAL" --filterName LowQualFilter --missingValuesInExpressionsShouldEvaluateAsFailing --variant Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam.Q20.vcf  --logging_level ERROR -o Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam.Q20.mark.vcf
  
  >grep -v "Filter" Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam.Q20.mark.vcf  > Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam.Q20.mark.filtered.vcf
  
  >/usr/local/jdk1.8.0_101/bin/java -Xmx100G -jar /share/app/GATK/GenomeAnalysisTK.jar -T SelectVariants -R Nothoprocta_perdicaria.fa --variant Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam.Q20.mark.filtered.vcf  -o Nothoprocta_perdicaria.fai.filter.clean.sorted.dedup.addrg.realign.recal.bam.Q20.mark.filtered.SNPs.vcf -selectType SNP
  


