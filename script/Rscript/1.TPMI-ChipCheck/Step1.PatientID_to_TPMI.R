setwd("./")

library(data.table)
library(dplyr)
library(broom)
library(MatchIt)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)

Input_list  <- args[1]
Output_name <- args[2]
Project <-     args[3]

# read file
Input<-fread(Input_list,sep="\t",header=T)
TPMI_list<-fread("//10.23.215.31/new_storage_1/bioinfo/GenePlatform/data/TPMI/TPMI_list.txt",sep="\t",header=T,encoding="UTF-8")

# Change column type
Input$PatientID<- as.character(Input$PatientID)
TPMI_list$PatientID<- as.character(TPMI_list$PatientID)

# Check duplicate
colnames(Input)[1]<-"PatientID"
colnames(Input)[2]<-"Pheno"
Input_unique<-distinct(Input,PatientID,.keep_all = T)

# Count number of duplicate
num_dup=nrow(Input)-nrow(Input_unique)
cat('\n')
cat('##### Input Sample Information #####')
cat('\n')
cat('\nInput Sample Num. is:', nrow(Input))
cat('\nInput Sample Num. duplicated is:', num_dup)
cat('\nInput Sample Num. unique is:', nrow(Input_unique))
cat('\n')

# Get Patients with (without) TPMI

Patient_List_TPMI<-left_join(Input,TPMI_list,by=c("PatientID"="PatientID"))

# Check duplicate

Patient_List_TPMI_unique=distinct(Patient_List_TPMI,PatientID,.keep_all = T)

# Get the list of TPMI with PatientID

no_chip=subset(Patient_List_TPMI_unique,is.na(Patient_List_TPMI_unique$Sex))
have_chip=subset(Patient_List_TPMI_unique,!is.na(Patient_List_TPMI_unique$Sex))

cat('\n')
cat('##### TPMI Chip Information #####')
cat('\n')
cat('\nSample Num. with TPMI chip is:', nrow(have_chip))
cat('\nSample Num. without TPMI chip is:', nrow(no_chip))
cat('\n')
cat('\n')

# Output the data
tmp_no_chip=paste0('./Result/',Project,'/',Output_name,'-no-chip.txt',collapse = '')
tmp_have_chip=paste0('./Result/',Project,'/',Output_name,'-have-chip.txt',collapse = '')

fwrite(no_chip,tmp_no_chip,sep="\t",col.names = T)
fwrite(have_chip,tmp_have_chip, sep="\t",col.names = T)