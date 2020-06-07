#make the bubble plot for Figure4,

# two types of the plot: 1) geom_circle 2) geom_dot
# To increase the space between strata and between species

library(ggplot2)
library(dplyr)
library(extrafont)
library(ggforce)
library(reshape2)
library(RColorBrewer)

args <- commandArgs(trailingOnly = TRUE)
timestring=Sys.Date()

path=args[1]

GR=read.table(paste(path,"/GeneRatio.ori.table",sep=""),sep="\t",header=T)
LR=read.table(paste(path,"/LengthRatio.ori.table",sep=""),sep = "\t",header = T)

#prepare the species order in numeric format, which can be used as Y axis for the geom_circle()
GR$order=c(15:1)
LR$order=c(15:1)
mGR=melt(GR,id.vars = c("Species","order"))
mLR=melt(LR,id.vars = c("Species","order"))

mGR$tag=paste(mGR$Species,mGR$variable)
mLR$tag=paste(mLR$Species,mLR$variable)

tab=merge(mGR,mLR,by="tag")

tabclean=tab[,c("Species.x","order.x","value.x","value.y","variable.x")]
colnames(tabclean)=c("Species","order","Gene","Length","Stratum")
tabclean$Gene=na_if(tabclean$Gene,0)
tabclean$Length=na_if(tabclean$Length,0)

#here is to make the X-axis to numeric in order to use the geom_circle
tabclean$Stratum=as.numeric(gsub("PAR","4", gsub("S","",tabclean$Stratum)))

tabnoPAR=tabclean[which(tabclean$Stratum <=3),]


#ggplot()+geom_circle(data=tabnoPAR,aes(x0=3-Stratum,y0=as.numeric(Species),r=Length,fill=Gene),color=NA,alpha=0.7)+scale_x_continuous(breaks = c(-1,0,1,2,3),labels = c("","S3","S2","S1","S0"),"Strata")+scale_y_continuous(breaks = as.numeric(unique(tabnoPAR$Species)),labels=unique(tabnoPAR$Species),"Species")+scale_fill_continuous(low = "#ffffcc",high = "#800026")+theme_bw()

speciesMap=unique(tabnoPAR[,1:2])
speciesMap=speciesMap[order(speciesMap$order),]

#without PAR

# plot_noPAR=ggplot()+geom_circle(data=tabnoPAR,aes(x0=(3-Stratum)*4,y0=order*2,r=Length,fill=Gene),alpha=0.7,color=NA,na.rm = T)+
#   scale_x_continuous(breaks = c(-1,0,1,2,3)*4,labels = c("","S3","S2","S1","S0"),"")+
#   scale_y_continuous(breaks = speciesMap$order*2,labels=speciesMap$Species,"")+scale_fill_gradientn(colours = rev(brewer.pal(n = 9,"RdYlBu")))+theme_bw()+
#   theme(text = element_text(family = "Arial Narrow"),axis.title = element_text(size=16),axis.text = element_text(size=14))
# ggsave(plot_noPAR,filename = paste(path,"/Total-strata",timestring,".pdf", sep=""),units = "cm",height = 14,width = 14)

#dot plot version 
plot_noPARdot=ggplot(data=tabnoPAR,aes(x=(3-Stratum),y=order,col=Gene,size=Length))+geom_point(na.rm = T,stroke=1.5)+
  scale_x_continuous(breaks = c(0,1,2,3),labels = c("S3","S2","S1","S0"),"",limits = c(-1,4)) +
  scale_y_continuous(breaks = speciesMap$order,labels=speciesMap$Species,"")+
  scale_size_continuous(labels = scales::percent_format(accuracy = 5L))+
  scale_color_gradientn(colours = rev(brewer.pal(n = 9,"RdYlBu")),labels = scales::percent_format(accuracy = 5L))+theme_bw()+
  theme(text = element_text(family = "Arial Narrow"),axis.text = element_text(size=14),panel.border = element_blank(),panel.grid = element_blank(),axis.ticks = element_line(color="grey"),axis.line=element_line(color ="grey"),legend.key.size = unit(0.5, "cm"),legend.key.height = unit(0.5,"cm"))+
  labs(color = "W/Z Gene",size="W/Z Length")
ggsave(plot_noPARdot,filename = paste(path,"/Total-strata-dot.2",timestring,".pdf",sep=""),units = "cm",height = 12,width = 14)
    

# #with PAR
# plot_PAR=ggplot()+geom_circle(data=tabclean,aes(x0=(4-Stratum)*4,y0=order*2,r=Length,fill=Gene),alpha=0.9, color=NA,na.rm = T)+
#   scale_x_continuous(breaks = c(0,1,2,3,4)*4,labels = c("PAR","S3","S2","S1","S0"),"")+
#   scale_y_continuous(breaks = speciesMap$order*2,labels=speciesMap$Species,"")+
#   scale_fill_gradientn(colours = rev(brewer.pal(n = 9,"RdYlBu")))+theme_bw()+
#   theme(text = element_text(family = "Arial Narrow"),axis.title = element_text(size=16),axis.text = element_text(size=14))
# ggsave(plot_PAR,filename = paste(path,"/Total-strata-withPAR",timestring,".pdf",sep=""),units = "cm",height = 14,width = 14)

#dotplot version

# plot_PARdot=ggplot(data=tabclean,aes(x=4-Stratum,y=order,col=Gene,size=Length))+geom_point(na.rm = T)+
#   scale_x_continuous(breaks = c(0,1,2,3,4),labels = c("PAR","S3","S2","S1","S0"),"")+
#   scale_y_continuous(breaks = speciesMap$order,labels=speciesMap$Species,"")+
#   scale_color_gradientn(colours = rev(brewer.pal(n = 9,"RdYlBu")))+theme_bw()+
#   theme(text = element_text(family = "Arial Narrow"),axis.title = element_text(size=16),axis.text = element_text(size=14),panel.border = element_blank(),panel.grid = element_blank(),axis.ticks = element_line(color="grey"),axis.line=element_line(color ="grey"))
# ggsave(plot_PARdot,filename = paste(path,"/Total-strata-withPAR-dot",timestring,".pdf",sep=""),units = "cm",height = 12,width = 15)

#The following section is used to selected species from the entire pool 

speciesSelcted=c("Ostrich","Southern cassowary","Greater rhea","Elegant crested tinamou","Chilean tinamou","Ornate tinamou","Tawny-breasted Tinamou","Thicket tinamou")
#speciesSelcted=c("Ostrich","Southern cassowary","Greater rhea","Ornate tinamou","Tawny-breasted Tinamou","Thicket tinamou")

GRs=subset(GR,Species %in% speciesSelcted)
LRs=subset(LR,Species %in% speciesSelcted)
#GRs$order=c(6:1)
#LRs$order=c(6:1)

GRs$order=c(8:1)
LRs$order=c(8:1)

mGRs=melt(GRs,id.vars = c("Species","order"))
mLRs=melt(LRs,id.vars = c("Species","order"))

mGRs$tag=paste(mGRs$Species,mGRs$variable)
mLRs$tag=paste(mLRs$Species,mLRs$variable)

tabS=merge(mGRs,mLRs,by="tag")

tabSclean=tabS[,c("Species.x","order.x","value.x","value.y","variable.x")]
colnames(tabSclean)=c("Species","order","Gene","Length","Stratum")
tabSclean$Gene=na_if(tabSclean$Gene,0)
tabSclean$Length=na_if(tabSclean$Length,0)

tabSclean$Stratum=as.numeric(gsub("PAR","4", gsub("S","",tabSclean$Stratum)))
tabSnoPAR=tabSclean[which(tabSclean$Stratum <=3),]

speciesMapS=unique(tabSnoPAR[,1:2])
speciesMapS=speciesMapS[order(speciesMapS$order),]

#psel=ggplot()+geom_circle(data=tabSnoPAR,aes(x0=(3-Stratum)*2,y0=order,r=Length,fill=Gene),alpha=0.9, color=NA,na.rm = T)+
#   scale_x_continuous(breaks = c(-1,0,1,2,3)*2,labels = c("","S3","S2","S1","S0"),"")+
#   scale_y_continuous(breaks = speciesMapS$order,labels=speciesMapS$Species,"")+
#   scale_fill_gradientn(colours = rev(brewer.pal(n = 9,"RdYlBu")))+theme_bw()+
#   theme(text = element_text(family = "Arial Narrow"),axis.title = element_text(size=16),axis.text = element_text(size=14),panel.border = element_blank(),panel.grid = element_blank(),axis.ticks = element_blank())
# ggsave(psel,filename = paste(path,"/strata-selected",timestring,".pdf",sep=""),units = "cm",height = 6,width = 11.5)

#the style changed 
# psel=ggplot()+geom_circle(data=tabSnoPAR,aes(x0=(3-Stratum)*2,y0=order,r=Length,fill=Gene),alpha=0.9, color=NA,na.rm = T)+
#   scale_x_continuous(breaks = c(-1,0,1,2,3)*2,labels = c("","S3","S2","S1","S0"),"")+
#   scale_y_continuous(breaks = speciesMapS$order,labels=speciesMapS$Species,"")+
#   scale_fill_gradientn(colours = rev(brewer.pal(n = 9,"RdYlBu")))+theme_bw()+
#   theme(text = element_text(family = "Arial Narrow"),axis.title = element_text(size=16),axis.text = element_text(size=14),panel.border = element_blank(),panel.grid = element_blank(),axis.ticks = element_line(color="grey"),axis.line=element_line(color ="grey"))
#  ggsave(psel,filename = paste(path,"/strata-selected",timestring,".pdf",sep=""),units = "cm",height = 6,width = 11.5)

#dotplot version


pseldot=ggplot(data=tabSnoPAR,aes(x=(3-Stratum)/2,y=order*2,col=Gene,size=Length))+geom_point(na.rm = T,stroke=1.5)+
  scale_x_continuous(breaks = c(-1,0,1,2,3)/2,labels = c("","S3","S2","S1","S0"),"",limits = c(-0.5,2))+
  scale_y_continuous(breaks = speciesMapS$order*2,labels=speciesMapS$Species,"")+
  scale_size_continuous(labels=scales::percent_format(accuracy = 5L))+
  scale_color_gradientn(colours = rev(brewer.pal(n = 9,"RdYlBu")),labels = scales::percent_format(accuracy = 5L))+theme_bw()+
  theme(text = element_text(family = "Arial Narrow"),axis.text = element_text(size=14),panel.border = element_blank(),panel.grid = element_blank(),axis.ticks = element_line(color="grey"),axis.line=element_line(color ="grey"),legend.key.size = unit(0.5, "cm"),legend.key.height = unit(0.5,"cm"))+
  labs(color = "W/Z Gene",size="W/Z Length")
ggsave(pseldot,filename = paste(path,"/strata-selected-dot.2",timestring,".pdf",sep=""),units = "cm",height = 9,width = 13)

