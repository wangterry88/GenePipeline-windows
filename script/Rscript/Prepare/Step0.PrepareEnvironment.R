####### Install packages ###########
#Sys.setlocale("LC_ALL","English")


setwd("./")

##### data.table ######
if("data.table" %in% rownames(installed.packages()) == FALSE) {
        install.packages("data.table",repos = "http://cran.us.r-project.org")
}
##### dplyr ######
if("dplyr" %in% rownames(installed.packages()) == FALSE) {
        install.packages("dplyr",repos = "http://cran.us.r-project.org")
}
#### ggplot2 ######
if("ggplot2" %in% rownames(installed.packages()) == FALSE) {
	install.packages("ggplot2",repos = "http://cran.us.r-project.org")
}
##### snpStats ######
if("snpStats" %in% rownames(installed.packages()) == FALSE) {
	if (!requireNamespace("BiocManager", quietly = TRUE))
   	install.packages("BiocManager",repos = "http://cran.us.r-project.org")
	BiocManager::install("snpStats")
}
##### qqman ######
if("qqman" %in% rownames(installed.packages()) == FALSE) {
	install.packages("qqman",repos = "http://cran.us.r-project.org")
}
if("pROC" %in% rownames(installed.packages()) == FALSE) {
	install.packages("pROC",repos = "http://cran.us.r-project.org")
}
##### MatchIt ######
if("MatchIt" %in% rownames(installed.packages()) == FALSE) {
        install.packages("MatchIt",repos = "http://cran.us.r-project.org")
}
##### broom ######
if("broom" %in% rownames(installed.packages()) == FALSE) {
        install.packages("broom",repos = "http://cran.us.r-project.org")
}
##### transport ######
if("transport" %in% rownames(installed.packages()) == FALSE) {
        install.packages("transport",repos = "http://cran.us.r-project.org")
}
##### survival ######
if("survival" %in% rownames(installed.packages()) == FALSE) {
        install.packages("survival",repos = "http://cran.us.r-project.org")
}
##### casebase ######
if("casebase" %in% rownames(installed.packages()) == FALSE) {
        install.packages("casebase",repos = "http://cran.us.r-project.org")
}
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {
        install.packages("tidyverse",repos = "http://cran.us.r-project.org")
}
if("wordcloud" %in% rownames(installed.packages()) == FALSE) {
	install.packages("wordcloud",repos = "http://cran.us.r-project.org")
}
if("igraph" %in% rownames(installed.packages()) == FALSE) {
        install.packages("igraph",repos = "http://cran.us.r-project.org")
}
if("showtext" %in% rownames(installed.packages()) == FALSE) {
        install.packages("showtext",repos = "http://cran.us.r-project.org")
}
if("stringr" %in% rownames(installed.packages()) == FALSE) {
        install.packages("stringr",repos = "http://cran.us.r-project.org")
}
if("remotes" %in% rownames(installed.packages()) == FALSE) {
        install.packages("remotes",repos = "http://cran.us.r-project.org")
}
if("gtsummary" %in% rownames(installed.packages()) == FALSE) {
        install.packages('./tools/zip/packages/stringi_1.7.12.zip',repos = NULL, type = "source")
        install.packages('./tools/zip/packages/evaluate_0.21.zip',repos = NULL, type = "source")
        install.packages('./tools/zip/packages/knitr_1.43.zip', repos = NULL, type = "source")
        install.packages("./tools/zip/packages/gtsummary_1.7.1.zip",repos = NULL, type = "source")
 }

library(stringi)
print("Package: stringi Checked!")
library(evaluate)
print("Package: evaluate Checked!")
library(knitr)
print("Package: knitr Checked!")
library(data.table)
print("Package: data.table Checked!")
library(dplyr)
print("Package: dplyr Checked!")
library(ggplot2)
print("Package: ggplot2 Checked!")
library(pROC)
print("Package: pROC Checked!")
library(broom)
print("Package: broom Checked!")
library(MatchIt)
print("Package: MatchIt Checked!")
library(transport)
print("Package: transport Checked!")
library(survival)
print("Package: survival Checked!")
library(casebase)
print("Package: casebase Checked!")
library(remotes)
print("Package: remotes Checked!")
library(gtsummary)
print("Package: gtsummary Checked!")
cat('\n')
cat('\n')
print("All Required Packages is installed successfully!.......")
