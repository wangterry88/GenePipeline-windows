setwd("./")

args <- commandArgs(trailingOnly = TRUE)

Input_list  <- args[1]
Output_name <- args[2]
Matching_Ratio_input <- args[3]
Project <-     args[4]

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
cat('The GWAS-ready Phenotype table was output in (Unmatched):',tmp_have_chip_GWAS)
cat('\n')
cat('\n')

control=subset(have_chip_GWAS,have_chip_GWAS$Pheno=="1")    
case=subset(have_chip_GWAS,have_chip_GWAS$Pheno=="2")

cat('\n')
cat('##### TPMI Chip for GWAS Information #####')
cat('\n')
cat('\nNum. of GWAS in control is:', nrow(control))
cat('\nNum. of GWAS in case is:', nrow(case))
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
cat("Your matching ratio is: ", Matching_Ratio)
cat('\n')
cat('\n')

# Perform Sex Age matching

have_chip_GWAS$Pheno<-recode_factor(have_chip_GWAS$Pheno,"1"="0","2"="1")

have_chip_GWAS.match <- matchit(Pheno ~ Age + Sex, data = have_chip_GWAS, method="nearest", ratio=Matching_Ratio)
have_chip_GWAS.match.df <-match.data(have_chip_GWAS.match)
have_chip_GWAS.match.df$Pheno<-recode_factor(have_chip_GWAS.match.df$Pheno,"0"="1","1"="2")

# Output the GWAS ready data
tmp_have_chip_GWAS.match.df=paste0('./Result/',Project,'/',Output_name,'.matched-data.txt',collapse = '')
fwrite(have_chip_GWAS.match.df,tmp_have_chip_GWAS.match.df, sep="\t",col.names = T)


#### Print case control information ####

control_match=subset(have_chip_GWAS.match.df,have_chip_GWAS.match.df$Pheno=="1")
case_match=subset(have_chip_GWAS.match.df,have_chip_GWAS.match.df$Pheno=="2")

cat('\n')
cat('##### TPMI Chip for GWAS Information (After Matching) #####')
cat('\n')
cat('\n Num. of GWAS in control is (Matched):', nrow(control_match))
cat('\n Num. of GWAS in    case is (Matched):', nrow(case_match))
cat('\n')
cat('\n')



# Prepare After Perform Matching plot

match_plot<-have_chip_GWAS.match.df

match_plot$Sex<-recode_factor(match_plot$Sex,"1"="Male","2"="Female")
match_plot$Pheno<-recode_factor(match_plot$Pheno,"1"="Control","2"="Case")

#  Age box plot  

tmp_mplot_age=paste0('./Result/',Project,'/',Output_name,'.match.age.png',collapse = '')

mplot_age=ggplot(match_plot,aes(x=Pheno,y=Age))+
    geom_boxplot(alpha=0.4, position = 'identity')+
    stat_summary(aes(label=sprintf("%1.1f", ..y..), color=factor(Pheno)),geom="text", 
                fun = function(y) boxplot.stats(y)$stats,position=position_nudge(x=0.45), size=3.5)+
    labs( x = "Stroke", y = "Count",title ="Age box plot in Matched data")
ggsave(mplot_age,file=tmp_mplot_age,height = 8,width  = 8)


#  Sex distribution plot   

tmp_mplot_sex=paste0('./Result/',Project,'/',Output_name,'.match.sex.png',collapse = '')

match_plot_df <- match_plot %>%
    filter(Sex %in% c("Male", "Female")) %>%
    group_by(Pheno, Sex) %>%
    summarise(counts = n()) 

mplot_sex=ggplot(match_plot_df, aes(x = Pheno, y = counts)) +
    geom_bar(aes(color = Sex, fill = Sex),stat = "identity", position = position_dodge(0.8),width = 0.7) +
    scale_color_manual(values = c("lightblue", "pink"))+
    scale_fill_manual(values = c("lightblue", "pink"))+
    geom_text(aes(label = counts, group = Sex), position = position_dodge(0.8),vjust = -0.3, size = 3.5)+
    labs( x = "Stroke", y = "Count",title ="Sex bar plot in Matched data")
ggsave(mplot_sex,file=tmp_mplot_sex,height = 8,width  = 8)

cat('\n')
cat('##### GWAS-ready Information (Afetr Matching) #####')
cat('\n')
cat('\nThe GWAS-ready Phenotype table was output in:',tmp_have_chip_GWAS.match.df)
cat('\n')
cat('\nReady for Next step: GWAS Analysis......')
cat('\n')
cat('\n')