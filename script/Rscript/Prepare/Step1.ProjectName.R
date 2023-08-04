options(echo=FALSE,warn=-1) # if you want see commands in output file #To turn warnings back on, use options(warn=0)
setwd("./")

args <- commandArgs(trailingOnly = TRUE)
Project_name<-args[1]

dir.create(paste0("./Result/",Project_name))
cat('\n')
cat('\n')
cat('Make Project Folder Sucessfully !...')
cat('\n')
cat('\n')
