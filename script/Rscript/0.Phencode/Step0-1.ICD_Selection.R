setwd("./")

args <- commandArgs(trailingOnly = TRUE)

ICD_input   <- args[1]
Output_name <- args[2]
Project     <- args[3]

##### Required packages #####

library(data.table)
library(dplyr)
library(ggplot2)
library(transport)
library(stringr)

cat('\n')
cat('\n')
cat('Preparing required data...... ')
cat('\n')
cat('\n')

##### Read ICD data #####

CodeBook<-fread("//10.23.215.31/new_storage_1/bioinfo/GenePlatform/data/Phencode/AIC_Phencode_ICD9_ICD10_codebook.txt",sep="\t",header=T)
TPMI_40W_phecode_table<-fread("//10.23.215.31/new_storage_1/bioinfo/GenePlatform/data/Phencode/AIC_Phencode_TPMI-40W_table.txt",sep="\t",header=T)

cat('\n')
cat('Required data loading successfully.....!')
cat('\n')
cat('\n')

##### search Phenotype Name by ICD codes ######

search_result<-
    CodeBook %>% 
        filter(if_any(everything(), ~ grepl(ICD_input, .)))

search_result_clean <- search_result %>% distinct()

search_result_clean_tmp<-paste0('./Result/',Project,'/',Output_name,'.ICD_phenotype_list.txt',collapse="")

fwrite(search_result_clean,search_result_clean_tmp,sep="\t",col.names = T)

##### Print the Results ######

cat('\n')
cat('\n')
cat('Your input ICD codes related Phenotype names is:')
cat('\n')
cat('\n')
print(unique(search_result_clean$Phenotype_Name))
cat('\n')
cat('\n')
cat('Your ICD codes related Phenotype critira is output at:',search_result_clean_tmp)
cat('\n')
cat('\n')

#### Print all sample number of the result list


phecode_AIC_list<-unique(search_result_clean$phecode_AIC)

Grep_col_table<-TPMI_40W_phecode_table %>% select(one_of(phecode_AIC_list))

df.col.name<-CodeBook$Phenotype_Name[match(names(Grep_col_table), CodeBook$phecode_AIC)]

colnames(Grep_col_table)<-df.col.name

Grep_col_table_CaseNo<-as.data.frame(colSums(Grep_col_table=='2'))

colnames(Grep_col_table_CaseNo)<-"Case_Num"

Grep_col_table_CaseNo <- tibble::rownames_to_column(Grep_col_table_CaseNo, "Disease_Name")

print(Grep_col_table_CaseNo)

output_tmp<-paste0('./Result/',Project,'/',Output_name,'.Phenotype_CaseNum.txt',collapse="")
fwrite(Grep_col_table_CaseNo,output_tmp,sep="\t",col.names = T)

cat('\n')
cat('\n')
cat('Please Right Click the Disease Name, and go to next step....')
cat('\n')
cat('\n')