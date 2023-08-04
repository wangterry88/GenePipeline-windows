setwd("./")

############ Required Packages ######################

library(data.table)
library(dplyr)
library(ggplot2)
library(pROC)
library(broom)
library(gtsummary)
library(MatchIt)
library(transport)
library(survival)
library(casebase)

###############################################################
cat('\n')
cat('\n')
cat("############ Step2: PGS calculate.....#################")
cat('\n')
cat('\n')
args = commandArgs(trailingOnly=TRUE)

output_name<-args[1]
Matching_Ratio_input<-args[2]
Project<-args[3]

Input_result<-paste0('./Result/',Project,'/output/PGS_of_intrested/',output_name,'_PGS-table.txt',collapse='')

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

######## Read User input table and perform sex age match ########

PRS.result.prsice<-fread(Input_result,sep="\t",header=T)
PRS.result.prsice<-na.omit(PRS.result.prsice)
PRS.result.prsice$Pheno<-as.factor(PRS.result.prsice$Pheno)

num_ctrl<-subset(PRS.result.prsice,PRS.result.prsice$Pheno=="1")
num_case<-subset(PRS.result.prsice,PRS.result.prsice$Pheno=="2")

cat('\n')
cat('\n')
cat('Control Num. of user input:',nrow(num_ctrl))
cat('\n')
cat('\n')
cat('Case Num. of user input:',nrow(num_case))
cat('\n')
cat('\n')

PRS.result.prsice.match <- matchit(Pheno ~ Age+Sex, data = PRS.result.prsice, method="nearest", ratio=Matching_Ratio)
PRS.result.prsice.match.df <-match.data(PRS.result.prsice.match)

num_ctrl_match<-subset(PRS.result.prsice.match.df ,PRS.result.prsice.match.df$Pheno=="1")
num_case_match<-subset(PRS.result.prsice.match.df ,PRS.result.prsice.match.df$Pheno=="2")

cat('\n')
cat('\n')
cat('Control Num. after sex-age-matching:',nrow(num_ctrl_match))
cat('\n')
cat('\n')
cat('Case Num. after sex-age-matching:',nrow(num_case_match))
cat('\n')
cat('\n')


############## Grep column names with "PGS" ####################

# Grep column names with "PGS"

pattern = "PGS"
pattern_PGS <- PRS.result.prsice.match.df[,grep(pattern = pattern, colnames(PRS.result.prsice.match.df))]
list_PGS<-colnames(PRS.result.prsice.match.df)[pattern_PGS]


############### Output related PGS lists ##################

list_PGS_output<-as.data.frame(t(list_PGS))
tmp_list_PGS_output<-paste0('./Result/',Project,'/Related_PGSID_List.txt')

fwrite(list_PGS_output,tmp_list_PGS_output,sep="|",col.names = F)

############# To select are we going to perform case control matching or not ##############

matching_type<-args[4]

if (matching_type == "1"){
  PRS.result.df=PRS.result.prsice.match.df
  print("Your selected data type is: Matching data")
  cat("Your matching ratio is: ", Matching_Ratio)
}else if(matching_type == "2") {
  PRS.result.df=PRS.result.prsice
  print("Your selected data type is: No Matching data")
}else {
  PRS.result.df=PRS.result.prsice.match.df
  print("(Default) Your selected data type is: Matching data")
  cat("Your matching ratio is: ", Matching_Ratio)
}


######## For loop Create dirctory ########

PGS_NUM <- list_PGS 

for (j in 1:length(PGS_NUM)){
  folder<-dir.create(paste0('./Result/',Project,'/output/',PGS_NUM[j]))
  sub_folder<-dir.create(paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/'))
}


######### Prepare plot data ########

for (j in 1:length(PGS_NUM)){

  ########################################################
  cat("\n")
  cat("\n")
  cat("###############################################")
  cat("\n")
  cat("\n")
  cat("The Program is now processing:",PGS_NUM[j])
  cat("\n")
  cat("\n")
  cat("###############################################\n")
  #########################################################
  
  select<-PGS_NUM[j]
  select_column<-c("PatientID","GenotypeName","Sex","Age","Pheno",select)

  PRS.result.plot<-select(PRS.result.df, matches(select_column))
  PRS.result.plot$Sex<-recode_factor(PRS.result.plot$Sex,"1"="Male","2"="Female")
  PRS.result.plot$Pheno<-recode_factor(PRS.result.plot$Pheno,"1"="Control","2"="Case")

######### Prepare model data ########

  PRS.result.model<-select(PRS.result.df, matches(select_column))
  PRS.result.model$Sex<-recode_factor(PRS.result.model$Sex,"1"="Male","2"="Female")
  PRS.result.model$Pheno<-recode_factor(PRS.result.model$Pheno,"1"="Control","2"="Case")

########## Ready plot data #########

  PRS.pheno.plot<-PRS.result.plot
  colnames(PRS.pheno.plot)<-c("PatientID","IID","Sex","Age","Pheno","SCORE")

# Plot data prepare
  PRS.pheno.plot$percentile<-ntile(PRS.pheno.plot$SCORE,10)

# Plot data output
  tmp_PRS.pheno.plot<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.plot-data.txt',collapse = '')
  fwrite(PRS.pheno.plot,tmp_PRS.pheno.plot,sep="\t",col.names=T)

# Plot info

  PRS.pheno.high10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile==10)
  PRS.pheno.low10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile==1)

  high10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile=="10")
  high10_line<-min(high10$SCORE)

  low10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile=="1")
  low10_line<-max(low10$SCORE)

  PRS.pheno.plot$percentile<-as.factor(PRS.pheno.plot$percentile)

  head(PRS.pheno.plot)
##################### Start Plotting ##############################

########## Distribution plot ##########

  tmp_dist_plot<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.distribution.png',collapse = '')
  

  dist_plot =ggplot(PRS.pheno.plot, aes(x=SCORE, fill=Pheno)) +
              geom_vline(aes(xintercept=high10_line), colour="#BB0000", linetype="dashed")+
              geom_vline(aes(xintercept=low10_line), colour="#BB0000", linetype="dashed")+
              geom_text(aes(x = high10_line,y=0.4,label = "High 10% PRS"))+
              geom_text(aes(x = low10_line,y=0.4,label = "Low 10% PRS"))+
              geom_density(alpha=0.4, position = 'identity')+
              scale_fill_manual( values = c("#00BFC4", "#F8766D"))

  ggsave(dist_plot,file=tmp_dist_plot,height = 8,width  = 8)

  #dev.off()

########## Plotting Coefficients on Odds Scale ##########

  # Fit regression model
  prs_glm <- glm(Pheno ~ percentile,data = PRS.pheno.plot,family = 'binomial')

  # Put results in data.frame
  summs <- prs_glm %>% summary()

  # Get point estimates and SEs
  results <- bind_cols(coef(prs_glm),summs$coefficients[, 2]) %>%
  setNames(c("estimate", "se"))  %>%
  mutate(percentile = 1:10)

  # Your coefficients are on the log odds scale, such that a coefficient is
  # log(odds_y==1 / odds_y == 0). We can exponentiate to get odds instead.
  results_odds <- results %>% mutate(across(.cols = -percentile, ~ exp(.x)))

  # Need SEs on the odds scale too
  results_odds <- results_odds %>%
    mutate(var_diag = diag(vcov(prs_glm)),
           se = sqrt(estimate ^ 2 * var_diag))

  out_df_or<-results_odds
  out_df_or<-as.data.frame(out_df_or)

  tmp_out_or<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.OR-data.txt')
  fwrite(out_df_or,tmp_out_or,sep="\t",col.names = T)



  # Plot with +/- 1 SE

  tmp_or_plot<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.OR-Plot.png',collapse = '')

  or_plot =ggplot(results_odds, aes(x = as.factor(percentile), y = estimate, color)) +
                    geom_point(stat = "identity", size=3,color = "black") +
                    geom_hline(yintercept = 1, linetype = "dashed", color = "grey") +
                    geom_errorbar(aes(ymin = estimate - se, ymax = estimate + se), width = 0.4) +
                    ggtitle("Odds Ratio in 1st to 10th PRS score") +
                    xlab("PRS Quantile") +
                    ylab("Odds")
  ggsave(or_plot,file=tmp_or_plot,height = 8,width  = 8)

########## Quantiles plot ##########

  tmp_quant_plot<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.quantiles.png',collapse = '')

 quant_plot<- PRS.pheno.plot %>%
   count(percentile, Pheno) %>%       
   group_by(percentile) %>%
   mutate(pct= prop.table(n) * 100) %>%
   ggplot() + aes(percentile, pct, fill=Pheno) +
                  geom_bar(stat="identity") +
                  xlab("Quantiles") +
                  ylab("Ratio of Case/Control") +
                  geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
                  position=position_stack(vjust=0.5)) +
                  ggtitle("PRS in 1st to 10th distribution") +
                  scale_fill_manual(values = c("#00BFC4", "#F8766D")) +
                  theme_bw()
    ggsave(quant_plot,file=tmp_quant_plot,height = 8,width  = 8)

########## Two sample T test: Case and control ########## 

  case<-subset(PRS.pheno.plot,PRS.pheno.plot$Pheno=="Case")
  ctrl<-subset(PRS.pheno.plot,PRS.pheno.plot$Pheno=="Control")

# Two sample T-test
  t.test.result<-tidy(t.test(case$SCORE,ctrl$SCORE))
  cat('\nP-value of PRS Case/Control distribution T-test is:',t.test.result$p.value)
  cat('\n')
  cat('\n')
  tmp_t_test<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.T-test.txt',collapse = '')
  fwrite(t.test.result,tmp_t_test,sep="\t",col.names = T)

# Wilcoxon Whitney U test , specify alternative="less"
  u.test.result<-tidy(wilcox.test(case$SCORE,ctrl$SCORE,alternative = "two.sided", paired = FALSE, exact = FALSE, correct = TRUE))
  cat('\nP-value of PRS Case/Control distribution U-test is:',u.test.result$p.value)
  cat('\n')
  cat('\n')
  tmp_u_test<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.U-test.txt',collapse = '')
  fwrite(u.test.result,tmp_u_test,sep="\t",col.names = T)

# Wasserstein distence test
  cat('\n')
  cat('Wasserstein distance is:',wasserstein1d(case$SCORE,ctrl$SCORE))
  cat('\n')
  tmp_Wass_test<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.Wasserstein-test.txt',collapse = '')
  cat('Wasserstein distance is:',wasserstein1d(case$SCORE,ctrl$SCORE),sep = "\t", file = tmp_Wass_test)

############################### Ready GLM PRS Model Data (Drop NA's) ########################################

  PRS.pheno.model=PRS.result.model
  PRS.pheno.model=na.omit(PRS.pheno.model)
  colnames(PRS.pheno.model)<-c("PatientID","IID","Sex","Age","Pheno","SCORE")
  cat('\n')
  cat('\n')
  cat('\n ###########################################')
  cat('\n')
  cat('\n')
  cat('\n PRS GLM model has dropped row with NAs....')
  cat('\n')
  cat('\n')
  cat('\n ###########################################')

##### 80% of the sample size #### 

  smp_size <- floor(0.8 * nrow(PRS.pheno.model))

## set the seed to make your partition reproducible
  set.seed(123)
  train_ind <- sample(seq_len(nrow(PRS.pheno.model)), size = smp_size)

##### Train data #####
  PRS.train.pheno <- PRS.pheno.model[train_ind, ]

##### Test data #####
  PRS.test.pheno <- PRS.pheno.model[-train_ind, ]

##### Train Test data output #####

  tmp.tarin.data<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.AUC.train-data.txt',collapse = '')
  fwrite(PRS.train.pheno,tmp.tarin.data,sep="\t",col.names=T)

  tmp.test.data<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.AUC.test-data.txt',collapse = '')
  fwrite(PRS.test.pheno,tmp.test.data,sep="\t",col.names=T)

### Summary of data ####
  cat('\n')
  cat('All data of PRS caculation:')
  cat('\n')
  cat('\n')
  summary(PRS.pheno.model)
  cat('\n')
  cat('\n')
  cat('Train data of PRS caculation:')
  cat('\n')
  cat('\n')
  summary(PRS.train.pheno)
  cat('\n')
  cat('\n')
  cat('Test data of PRS caculation:')
  cat('\n')
  cat('\n')
  summary(PRS.test.pheno)
  cat('\n')
  cat('\n')

##################################### Model 2 (PRS only) #####################################

  library(pROC)

  mod_2 <- glm( Pheno ~ SCORE, data=PRS.train.pheno, family="binomial")

# Get probability of model

  train_2_prob = predict(mod_2, data=PRS.train.pheno ,type='response')
  train_2_roc = roc(PRS.train.pheno$Pheno ~ train_2_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

  ##################################################################################################################

  ## Test
  test_2_prob = predict(mod_2, newdata = PRS.test.pheno, type = "response")
  test_2_roc = roc(PRS.test.pheno$Pheno ~ test_2_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

 ## Plot
 # plot(test_2_roc,print.auc = TRUE, print.auc.y = .3 , col='red')
 # text(0.15, .3, paste("PRS Model"))


######################## AUC plot Table ################################

## Table Output

  out_a=coords(test_2_roc, "best", ret = c("auc","threshold", "specificity", "sensitivity", "accuracy","precision", "recall"), transpose = FALSE, print.auc = TRUE)

  #Get the first row to prevent error of 2 rows of metrics
  out_a=out_a[1,]
  out_b=as.data.frame(auc(test_2_roc))

  colnames(out_b)<-"AUC"
  out_final<-cbind(out_a,out_b)

  tmp_out<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.Performance.txt',collapse = '')
  fwrite(out_final,tmp_out,sep="\t",col.names = T)


### Model plot ###

    tmp_model_plot<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.AUCs.png',collapse = '')

    png(tmp_model_plot,height = 500,width  = 500)

    test_2_roc = roc(PRS.test.pheno$Pheno ~ test_2_prob)
    plot(test_2_roc,print.auc = TRUE, print.auc.y = .3 , col='red')

    text(0.15, .3, paste("PRS Model"))
    cat('\n')
    cat('\n')
    cat('\nAUC of PRS Model is:', auc(test_2_roc))
    cat('\n')
    dev.off()
    cat('\n')

################# Table 1 of PRS Sample in GLM model (Dropped NAs) #################

  cat('##### Table 1 of PRS Sample in GLM model (Dropped NAs) #####')
  cat('\n')
  cat('\n')

  table_PRS=PRS.pheno.model
  #table_PRS$Pheno<-recode_factor(table_PRS$Pheno,"1"="Control","2"="Case")
  #table_PRS$Sex<-recode_factor(table_PRS$Sex,"1"="Male","2"="Female")

  cov = c('Pheno','Sex','Age')
  table_PRS_print <- table_PRS %>% select(cov)

  tmp_PRS_table1<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.table1.html',collapse = '')

  table1 <- 
    tbl_summary(
      table_PRS_print,
      by = Pheno, # split table by group
      missing = "no" # don't list missing data separately
    ) %>%
    add_n() %>% # add column with total number of non-missing observations
    add_p() %>% # test for a difference between groups
    modify_header(label = "**Covarites**") %>% # update the column header
    bold_labels() 

  table1%>%
    as_gt() %>%
    gt::gtsave(filename = tmp_PRS_table1)
    
  cat('\n')
  cat('\nPRS Pheno table1 is in:',tmp_PRS_table1)
  cat('\n')
  cat('\n')


######################## Prevalence plot and Table ################################

  Prevalence.plot<-PRS.pheno.plot
  Prevalence.plot$Pheno<-recode_factor(Prevalence.plot$Pheno,"Control"="0","Case"="1")
  Prevalence.plot$Pheno<-as.numeric(as.character(Prevalence.plot$Pheno))
  Prevalence.plot$percentile<-as.factor(Prevalence.plot$percentile)
  Prevalence.plot$PrevalenceGroup<-ntile(Prevalence.plot$SCORE,100)

  PrevalencePlot_data<-Prevalence.plot %>% 
  group_by(PrevalenceGroup) %>% 
  summarise(Prevalence = sum(Pheno)/n())

  tmp_PrevalencePlot_data<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.Prevalence-data.txt')
  fwrite(PrevalencePlot_data,tmp_PrevalencePlot_data,sep="\t",col.names = T)


  tmp_Prevalence_plot<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.Prevalence.png')
        
  Prevalence_plot<-ggplot(PrevalencePlot_data, aes(x=PrevalenceGroup, y=Prevalence)) + 
  labs( x = "Percentile of PRS", y = "Prevalence",title ="Prevalence of Disease")+
  geom_point()

  ggsave(Prevalence_plot,file=tmp_Prevalence_plot,height = 8,width  = 8)


######################## Cumulative Risk plot and Table ################################

    Cumulative.plot<-PRS.pheno.plot


    Cumulative.plot$Pheno<-recode_factor(Cumulative.plot$Pheno,"Control"="0","Case"="1")
    Cumulative.plot$Pheno<-as.numeric(as.character(Cumulative.plot$Pheno))
    Cumulative.plot$percentile<-as.factor(Cumulative.plot$percentile)
    Cumulative.plot$PrevalenceGroup<-ntile(Cumulative.plot$SCORE,100)

    Cumulative.plot<-Cumulative.plot[order(Cumulative.plot$SCORE),]
    Cumulative.plot$Index<-1:nrow(Cumulative.plot)
    cumplot_glm <- fitSmoothHazard(Pheno ~ Age+SCORE,data = Cumulative.plot, time = "Age", ratio = 10)

    #summary(cumplot_glm)

    group_25<-subset(Cumulative.plot,Cumulative.plot$PrevalenceGroup=="25")
    group_50<-subset(Cumulative.plot,Cumulative.plot$PrevalenceGroup=="50")
    group_75<-subset(Cumulative.plot,Cumulative.plot$PrevalenceGroup=="75")
    group_100<-subset(Cumulative.plot,Cumulative.plot$PrevalenceGroup=="100")

    sample_25<-min(group_25$Index)
    sample_50<-min(group_50$Index)
    sample_75<-min(group_75$Index)
    sample_100<-min(group_100$Index)

    smooth_risk_model <- absoluteRisk(object = cumplot_glm, newdata = Cumulative.plot[c(sample_25,sample_50,sample_75,sample_100),])

    risk_data<-as.data.frame(smooth_risk_model)
    colnames(risk_data)<-c("Age-Time","PRS-25%","PRS-50%","PRS-75%","PRS-100%")

    tmp_risk_data<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.Cumulative_Risk-data.txt')
    fwrite(risk_data,tmp_risk_data,sep="\t",col.names = T,row.names=F)

    tmp_risk_plot<-paste0('./Result/',Project,'/output/',PGS_NUM[j],'/plot/',PGS_NUM[j],'.Cumulative_Risk.png')

    smooth_risk <- absoluteRisk(object = cumplot_glm, newdata = Cumulative.plot[c(sample_25,sample_50,sample_75,sample_100),])

    png(tmp_risk_plot,height = 800,width  = 800)
    fullplot<-plot(smooth_risk,
          id.names = c("PRS 25%","PRS 50%","PRS 75%","PRS 100%"), 
          legend.title = "PRS", 
          xlab = "Age (Years Old)", 
          ylab = "Cumulative Incidence (%)")
    print(fullplot)
    dev.off()

}