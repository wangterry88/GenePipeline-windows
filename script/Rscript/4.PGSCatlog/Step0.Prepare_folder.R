setwd("./")

args <- commandArgs(trailingOnly = TRUE)
Project_name<-args[1]

dir.create(paste0("./Result/",Project_name,"/output"))
dir.create(paste0("./Result/",Project_name,"/output/PGS_of_intrested"))

cat('\n')
cat('\n')
cat('Make Project Required Folder Sucessfully !...')
cat('\n')
cat('\n')

