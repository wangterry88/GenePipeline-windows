setwd("./")

library(data.table)
library(dplyr)

cat('\n')
cat('\n')
cat("############ Step3: PGS info.....#################")
cat('\n')
cat('\n')

args = commandArgs(trailingOnly=TRUE)

Data_type<-args[1]
Project<-args[2]

PGSID_List<-paste0('./Result/',Project,'/Related_PGSID_List.txt',collapse='')
list_PGS_print<-fread(PGSID_List,sep=",",header=F)

cat("\n")
cat("\n")

LIST<-list_PGS_print[1,]

################ Required data prepare: #########################

######### Select data: #######

tmp_30W<-c("//10.23.215.31/new_storage_1/bioinfo/GenePlatform/data/PGScatlog/TPMI-imputed/PGSCatlog-information-30W.txt")
tmp_40W<-c("//10.23.215.31/new_storage_1/bioinfo/GenePlatform/data/PGScatlog/TPMI-imputed/PGSCatlog-information-40W.txt")

if (Data_type == "1"){
    selected_data_type=tmp_30W
    print("Your selected data type is: 30W data")
    cat('\n')
}else if(Data_type == "2") {
    selected_data_type=tmp_40W
    print("Your selected data type is: 40W data")
    cat('\n')
}else {
    selected_data_type=tmp_40W
    print("Your selected data type is: 40W data (default)")
    cat('\n')
}

PGS_SNP_info<-fread(selected_data_type,sep="\t",header= T)

search_list<-LIST

PGS_SNP_info_select<-PGS_SNP_info[grepl(search_list,PGS_SNP_info$PGSID),]

cat('\n')
print(PGS_SNP_info_select)
cat('\n')

PGS_SNP_info_select_tmp<-paste0('./Result/',Project,'/Related_PGSID_List_SNPinfo.txt',collapse='')
fwrite(PGS_SNP_info_select,PGS_SNP_info_select_tmp,sep="\t",col.names=T)

cat('############ Step3 Done......############')

cat('\n')
cat('\n')