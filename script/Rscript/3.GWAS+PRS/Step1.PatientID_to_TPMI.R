setwd("./")

args <- commandArgs(trailingOnly = TRUE)

Input_list  <- args[1]
Output_name <- args[2]
Matching_Ratio_input <- args[3]
training_rate <-args[4]
Project <-     args[5]


library(data.table)
library(dplyr)
library(broom)
library(MatchIt)
library(ggplot2)

# read file

Input<-fread(Input_list,sep="\t",header=T)
TPMI_list<-fread("//10.23.215.31/new_storage_1/bioinfo/GenePlatform/data/TPMI/TPMI_list.txt",sep="\t",header=T)

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


# Make the GWAS-ready Pheno table

have_chip_GWAS=have_chip[,c("GenotypeName","GenotypeName","Sex","Age","Pheno")]
colnames(have_chip_GWAS)<-c("FID","IID","Sex","Age","Pheno")

# Output the raw GWAS-ready table

tmp_have_chip_GWAS=paste0('./Result/',Project,'/',Output_name,'.RAW-pheno-data.txt',collapse = '')
fwrite(have_chip_GWAS,tmp_have_chip_GWAS, sep="\t",col.names = T)

cat('\n')
cat('\n')
cat('The Full-ready Phenotype table was output in (Unmatched):',tmp_have_chip_GWAS)
cat('\n')
cat('\n')

control=subset(have_chip_GWAS,have_chip_GWAS$Pheno=="1")    
case=subset(have_chip_GWAS,have_chip_GWAS$Pheno=="2")

cat('\n')
cat('##### TPMI Chip for Full Information #####')
cat('\n')
cat('\nNum. of Full in control is:', nrow(control))
cat('\nNum. of Full in case is:', nrow(case))
cat('\n')
cat('\n')

cat('\n')
cat('\n')
cat('##### Perform Age Sex matching...... #####')
cat('\n')

if (as.numeric(Matching_Ratio_input) > 10){
    print("Your matching ratio is too high, we will use default ratio: 4")
    Matching_Ratio=4
}else if(as.numeric(Matching_Ratio_input) <= 0) {
    print("Your matching ratio must be a positive number, we will use default ratio: 4")
    Matching_Ratio=4
}else {
    cat("Your matching ratio is: ", Matching_Ratio_input)
    Matching_Ratio=as.numeric(Matching_Ratio_input)
}

cat('\n')
cat('\n')

# Perform Sex Age matching

have_chip_GWAS$Pheno<-recode_factor(have_chip_GWAS$Pheno,"1"="0","2"="1")

have_chip_GWAS.match <- matchit(Pheno ~ Age + Sex, data = have_chip_GWAS, method="nearest", ratio=Matching_Ratio)
have_chip_GWAS.match.df <-match.data(have_chip_GWAS.match)
have_chip_GWAS.match.df$Pheno<-recode_factor(have_chip_GWAS.match.df$Pheno,"0"="1","1"="2")

# Output the GWAS ready data
tmp_have_chip_GWAS.match.df=paste0('./Result/',Project,'/pheno/',Output_name,'.Full-matched-data.txt',collapse = '')
fwrite(have_chip_GWAS.match.df,tmp_have_chip_GWAS.match.df, sep="\t",col.names = T)


#### Print case control information ####

control_match=subset(have_chip_GWAS.match.df,have_chip_GWAS.match.df$Pheno=="1")
case_match=subset(have_chip_GWAS.match.df,have_chip_GWAS.match.df$Pheno=="2")

cat('\n')
cat('##### TPMI Chip for ALL Information (Matched) #####')
cat('\n')
cat('\n Num. of Full data in control is (Matched):', nrow(control_match))
cat('\n Num. of Full data in case is (Matched):', nrow(case_match))
cat('\n')
cat('\n')

##### Get Full data to GWAS + PRS ########

if (as.numeric(training_rate) > 0.9){
    print("Your training ratio [must be a number <= 0.9], now use default ratio: 0.8")
    training_rate=0.8
}else if(as.numeric(training_rate) <= 0.49) {
    print("Your training ratio [must be a number >= 0.5], now use default ratio: 0.8")
    training_rate=0.8
}else {
    cat("Your training ratio is: ", training_rate)
    training_rate=as.numeric(training_rate)
}

### Control ####

smp_size_control <- floor(training_rate * nrow(control_match))
train_ind_control <- sample(seq_len(nrow(control_match)), size = smp_size_control)

train_control <- control_match[train_ind_control, ]
test_control <-  control_match[-train_ind_control, ]

### Case ####

smp_size_case <- floor(training_rate * nrow(case_match))
train_ind_case <- sample(seq_len(nrow(case_match)), size = smp_size_case)

train_case <- case_match[train_ind_case, ]
test_case <-  case_match[-train_ind_case, ]

# Combine the randomm seleted case control data

train.data<-rbind(train_control,train_case)
test.data<-rbind(test_control,test_case)

# Information of GWAS PRS data

cat('\n')
cat('\n')
cat('##### Information of GWAS data  #####')
cat('\n')
cat('\n')
train.data$Pheno<-as.factor(train.data$Pheno)
summary(train.data)
cat('\n')
cat('##### Information of PRS data  #####')
cat('\n')
cat('\n')
test.data$Pheno<-as.factor(test.data$Pheno)
summary(test.data)
cat('\n')

tmp_gwas=paste0('./Result/',Project,'/pheno/',Output_name,'.GWAS.pheno.txt',collapse = '')
tmp_prs=paste0('./Result/',Project,'/pheno/',Output_name,'.PRS.pheno.txt',collapse = '')

fwrite(train.data,tmp_gwas,sep="\t",col.names = T)
fwrite(test.data,tmp_prs, sep="\t",col.names = T)

cat('\n')
cat('##### GWAS-ready Information #####')
cat('\n')
cat('\n The GWAS-ready Phenotype table was output in:',tmp_gwas)
cat('\n')
cat('\n')
cat('##### PRS-ready Information #####')
cat('\n')
cat('\n The PRS-ready Phenotype table was output in:',tmp_prs)
cat('\n')
cat('\n')
cat('##### GWAS PRS Sepration successfully #####\n')
cat('\n')
cat('\n')