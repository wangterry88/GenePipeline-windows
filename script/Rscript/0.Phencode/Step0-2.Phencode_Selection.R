setwd("./")

##### Required packages #####

library(data.table)
library(dplyr)

##### Read data #####

args <- commandArgs(trailingOnly = TRUE)

phenotype_input<-args[1]
Project<-args[2]

cat('\n')
cat('\n')
cat('Preparing required data...... ')
cat('\n')
cat('\n')

CodeBook<-fread("//10.23.215.31/new_storage_1/bioinfo/GenePlatform/data/Phencode/AIC_Phencode_ICD9_ICD10_codebook.txt",sep="\t",header=T)
TPMI_40W_phecode_table<-fread("//10.23.215.31/new_storage_1/bioinfo/GenePlatform/data/Phencode/AIC_Phencode_TPMI-40W_table.txt",sep="\t",header=T)

cat('\n')
cat('Required data loading successfully.....!')
cat('\n')
cat('\n')

# Search data for input information

# Get the full match pattern for grepl

mapping_pattern <-paste0('^',phenotype_input,'$',collapse='')


phenotype_search_result<-
    CodeBook %>% 
        filter(if_any(everything(), ~ grepl(mapping_pattern, .)))

result_AIC_code<-unique(phenotype_search_result$phecode_AIC)

# Make selction columns

select_col<-append(c("PatientID"),result_AIC_code)

phecode_select_table<-TPMI_40W_phecode_table %>% select(one_of(select_col))

# Convert coluum name with mapping table 

colnames(phecode_select_table)[2]<-CodeBook$Phenotype_Name[match(colnames(phecode_select_table)[2],CodeBook$phecode_AIC)]

# Get selection name column

select_name<-colnames(phecode_select_table)[2]

# Remove rows with -9

select_output<-phecode_select_table %>%
  filter(if_any(select_name, ~ !(.x %in% c("-9"))))


select_output_tmp<-paste0('./Result/',Project,'/Phencode_selected_list.txt',collapse="")
fwrite(select_output,select_output_tmp,sep="\t",col.names = T)

####### Print the Case Control Number of selected data #######

ctrl<-filter(select_output, select_output[,2] == "1")  
case<-filter(select_output, select_output[,2] == "2")  

cat('\n')
cat('\n')
cat('Number of Control with user select is:',nrow(ctrl))
cat('\n')
cat('Number of Case with user select is:',nrow(case))
cat('\n')
cat('Selected disease list is output in:',select_output_tmp)
cat('\n')
cat('\n')