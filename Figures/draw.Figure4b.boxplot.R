args = commandArgs(T)
pdf(args[1])

library(ggplot2)
data <- read.table(args[2],header=T,sep='\t')
p=ggplot(data) +   geom_boxplot(aes(x = factor(group),y =Percent,color=factor(group)),outlier.colour=NA,size = 1,width=.5,position=position_dodge(0.6)) + theme(plot.title = element_text(hjust = 0.5, vjust=0,size=rel(1.5), family="Times",face="bold.italic")) + theme(axis.text.x = element_text(colour = 'black', angle = 0, size = 15, hjust = 0.5, vjust = 0.5), axis.text.y = element_text( angle = 0, size = 15, hjust = 0.5, vjust = 0.5), axis.title.y = element_text(size = rel(1.5), angle = 90)) + ylab("Retained W-linked genes %") + xlab("") + theme(legend.position="none") + guides(fill=FALSE) #+ ggtitle(args[3])
plot(p)
