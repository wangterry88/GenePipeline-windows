setwd("./")

args <- commandArgs(trailingOnly = TRUE)

GENE_RESULT <-args[1]
PLOT_OUT <- args[2]
Project <-args[3]

library(data.table)
library(dplyr)
library(ggplot2)
library(snpStats)
library(qqman)

gwas.result<-read.table(GENE_RESULT,sep="",header = T)

manhattan_data_clean<-na.omit(gwas.result)

manhattan_data<-manhattan_data_clean[,c("CHR","BP","ANNOT","P")]

colnames(manhattan_data)[1]<-"CHR"
colnames(manhattan_data)[2]<-"BP"
colnames(manhattan_data)[3]<-"SNP"
colnames(manhattan_data)[4]<-"P"

manhattan_data$CHR<-as.numeric(manhattan_data$CHR)
manhattan_data_nosex<-subset(manhattan_data,manhattan_data$CHR<23)

tmp_manhattan_gene=paste0('./Result/',Project,'/GWAS/plot/',PLOT_OUT,'.gene.manhattan.png',collapse = '')

png(file=tmp_manhattan_gene, width = 2000,height = 1000,pointsize = 18)
par(cex=1.2)

color_set <-c("#8DA0CB","#E78AC3","#A6D854","#FFD92F","#E5C494","#66C2A5","#FC8D62")

manhattan(manhattan_data_nosex,
          col = color_set,
          suggestiveline = -log10(1e-05),
          genomewideline = -log10(5e-08),
          logp = T,
          annotatePval = 1e-05,
          annotateTop=FALSE
)
dev.off()


# Output information

cat('\n')
cat('\n')
cat('Manhhatan plot is output at:',tmp_manhattan_gene)
cat('\n')
cat('\n')
