setwd("./")

args <- commandArgs(trailingOnly = TRUE)
Project_name<-args[1]

dir.create(paste0("./Result/",Project_name,"/GWAS"))
dir.create(paste0("./Result/",Project_name,"/GWAS/plot"))

cat('\n')
cat('\n')
cat('Make Project Required Folder Sucessfully !...')
cat('\n')
cat('\n')

