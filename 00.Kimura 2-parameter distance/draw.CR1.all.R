library(ggplot2)
args <- commandArgs(T)

pdf(args[1],width=9,height=10)
md <- read.table(args[2],head=T,sep="\t")

p = ggplot(transform(md,species=factor(species,levels=c("Ostrich","Brown kiwi","Emu","Southern cassowary","Greater rhea","Ornate tinamou","Andean tinamou","Chilean tinamou","Elegant crested tinamou","Tawny-breasted Tinamou","Hooded tinamou","Thicket tinamou","Little tinamou","Undulated tinamou","White-throated tinamou"))),aes(x=divergence, y=percent,fill = type)) + geom_bar(stat="identity")

palette <- c("#e41a1c","#377eb8","#4daf4a","#984ea3","#ff7f00","#ffff33","#a65628")

p = p + scale_fill_manual(values=palette) + facet_wrap(~species, nrow = 8)

p = p + theme(axis.text.y=element_text(size=10),axis.text.x=element_text(size=10),axis.title.x=element_text(size=20,face="bold"),axis.title.y=element_text(size=20,face="bold")) + labs(size= "Nitrogen", x="Sequence divergence percent",y = "Genome percent") + xlim(0, 60) + ylim(0,5) + theme(legend.position = c(0.8, 0))

plot(p)
