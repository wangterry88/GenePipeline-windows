setwd("./")

args <- commandArgs(trailingOnly = TRUE)
Project_name<-args[1]

dir.create(paste0("./Result/",Project_name,"/GWAS"))
dir.create(paste0("./Result/",Project_name,"/GWAS/plot"))
dir.create(paste0("./Result/",Project_name,"/PRS"))
dir.create(paste0("./Result/",Project_name,"/PRS/data"))
dir.create(paste0("./Result/",Project_name,"/PRS/plot"))
dir.create(paste0("./Result/",Project_name,"/PRS/result"))
dir.create(paste0("./Result/",Project_name,"/pheno"))

cat('\n')
cat('\n')
cat('Make Project Required Folder Sucessfully !...')
cat('\n')
cat('\n')

