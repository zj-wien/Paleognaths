**Here we provide scripts to extract Kimura 2-parameter distance from RepeatMasker and to draw bar charts with ggplot2.**

1. extract Kimura 2-parameter distance for each repeat element.
 
  > perl divergence.pl RepeatMasker.output.directory RepeatMasker.output.directory > all.kimura.div
  
2. pick up candidate TE elements and format them to plot.

   additional input file: genome.fa.len

   The file format is tab delimited, first column is element Name and second is its order. 
  
    e.g. CR1-Y2_Aves     1

  > perl format.divergence.pl all.kimura.div.gz CR1.candidate.1.list > CR1.candidate.1.list.data
 
3. plot bar charts

  > Rscript draw.CR1.all.R CR1.candidate.1.list.data.all.pdf CR1.candidate.1.list.data


