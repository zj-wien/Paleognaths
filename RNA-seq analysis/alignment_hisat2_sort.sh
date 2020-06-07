#!/bin/bash
date

for i in *1.fastq.gz; 
do
    i=${i%1.fastq.gz*}; 
    nohup hisat2 -p 8 --dta -x /public1/home/xiaoman/RNAseq_analysis/01.genome_index/Nothoprocta_perdicaria/Nothoprocta_perdicaria -1 /public1/home/xiaoman/RNAseq_analysis/00.data/Nothoprocta_perdicaria/${i}1.fastq.gz -2 /public1/home/xiaoman/RNAseq_analysis/00.data/Nothoprocta_perdicaria/${i}2.fastq.gz | samtools sort -@ 8 -o ${i}.bam > /public1/home/xiaoman/RNAseq_analysis/02.alignment_hisat2/Nothoprocta_perdicaria/${i}align.log 2>&1 &
done

date
