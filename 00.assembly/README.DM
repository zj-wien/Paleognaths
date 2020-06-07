#de novo genome assembly using SOAPdenovo2#

SOAPdenovo-63mer  pregraph -s Nothoprocta_perdicaria.cfg -K 37 -d 3 -R -p 5  -o Nothoprocta_perdicaria  2>./pregraph.log
SOAPdenovo-63mer contig -g Nothoprocta_perdicaria -M 3 2>./contig.log
SOAPdenovo-63mer map -s Nothoprocta_perdicaria.cfg  -p 5 -g Nothoprocta_perdicaria 2>map.log
SOAPdenovo-63mer scaff -F -g Nothoprocta_perdicaria -p 5 2>scaff.log
