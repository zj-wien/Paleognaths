args = commandArgs(T)
pdf(args[1],width=9,height=12)
library(ggplot2)

data <- read.table(args[2],header=T,sep="\t")

p = ggplot(transform(data,species=factor(species,levels=c("Ostrich", "Brown kiwi","Emu","Southern cassowary","Greater rhea","Ornate tinamou","Andean tinamou","Chilean tinamou","Elegant crested tinamou","Tawny-breasted Tinamou","Hooded tinamou","Thicket tinamou","Little tinamou","Undulated tinamou","White-throated tinamou"))),aes(x=position/1000/1000,y =Ks,colour=stratum))  + geom_point(alpha = 0.8, size = 2)

p = p + facet_wrap(~species, nrow = 5,scales = "free") + xlab("chrZ (Mb)") + ylab("Ks") +  theme(plot.title = element_text(hjust = 0.5, vjust=0,size=rel(1.5), family="Times",face="bold")) + theme(axis.text.x = element_text(colour = 'black', angle = 0, size = 15, hjust = 0.5, vjust = 0.5), axis.text.y = element_text( angle = 0, size = 15, hjust = 0.5, vjust = 0.5), axis.title.y = element_text(size = rel(1.5), angle = 90), axis.title.x = element_text(size = rel(1.5), angle = 0)) + theme(legend.position = c(0.8, 0.95))
plot(p)


#ggplot(data, aes(x = position/1000/1000,y =Ks,colour=stratum)) + geom_point(alpha = 1, size = 3) + ggtitle(args[3]) + xlab("chrZ (Mb)") + ylab("Ks") +  theme(plot.title = element_text(hjust = 0.5, vjust=0,size=rel(1.5), family="Times",face="bold")) + theme(axis.text.x = element_text(colour = 'black', angle = 0, size = 15, hjust = 0.5, vjust = 0.5), axis.text.y = element_text( angle = 0, size = 15, hjust = 0.5, vjust = 0.5), axis.title.y = element_text(size = rel(1.5), angle = 90), axis.title.x = element_text(size = rel(1.5), angle = 0)) 

