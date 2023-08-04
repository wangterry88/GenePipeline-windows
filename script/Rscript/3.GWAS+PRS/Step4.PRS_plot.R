setwd("./")
#############

args <- commandArgs(trailingOnly = TRUE)

PRS_RESULT<-args[1]
PHENO<-args[2]
PLOT_OUT<-args[3]
Project<-args[4]

############# Required Packages ###############

library(data.table)
library(dplyr)
library(ggplot2)
library(pROC)
library(broom)
library(gtsummary)
library(MatchIt)
library(transport)

#############################

PRS.result.prsice<-fread(PRS_RESULT)
CMUH.pheno<-fread(PHENO,sep="\t",header=T)

head(PRS.result.prsice)
head(CMUH.pheno)

Prsice.pheno<-inner_join(PRS.result.prsice,CMUH.pheno,by=c("FID"="FID","IID"="IID"))
Prsice.pheno<-na.omit(Prsice.pheno)

# Prepare Plot data
Prsice.pheno.plot<-Prsice.pheno[,c("FID","IID","PRS","Sex","Age","Pheno")]
Prsice.pheno.plot$Sex<-recode_factor(Prsice.pheno.plot$Sex,"1"="Male","2"="Female")
Prsice.pheno.plot$Pheno<-recode_factor(Prsice.pheno.plot$Pheno,"1"="Control","2"="Case")

# Prepare model data

Prsice.pheno.model<-Prsice.pheno[,c("FID","IID","PRS","Sex","Age","Pheno")]
Prsice.pheno.model$Sex<-as.factor(Prsice.pheno.model$Sex)
Prsice.pheno.model$Pheno<-as.factor(Prsice.pheno.model$Pheno)

# Ready plot data

PRS.pheno.plot<-Prsice.pheno.plot
colnames(PRS.pheno.plot)<-c("FID","IID","SCORE","Sex","Age","Pheno")

# Plot data prepare

PRS.pheno.plot$percentile<-ntile(PRS.pheno.plot$SCORE,10)

# Plot data output

tmp.PRS.pheno.plot<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.plot-data.txt',collapse = '')
fwrite(PRS.pheno.plot,tmp.PRS.pheno.plot,sep="\t",col.names=T)


# Plot info

PRS.pheno.high10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile==10)
PRS.pheno.low10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile==1)

high10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile=="10")
high10_line<-min(high10$SCORE)

low10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile=="1")
low10_line<-max(low10$SCORE)

PRS.pheno.plot$percentile<-as.factor(PRS.pheno.plot$percentile)
 
### Plotting Coefficients on Odds Scale ###

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
results_odds <- results %>% mutate(across(.cols = -percentile,
                                          ~ exp(.x)))

# Need SEs on the odds scale too
results_odds <- results_odds %>%
  mutate(var_diag = diag(vcov(prs_glm)),
         se = sqrt(estimate ^ 2 * var_diag))

# Plot with +/- 1 SE

tmp_or_plot<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.OR-Plot.png',collapse = '')

#png(tmp_or_plot,height = 500,width  = 500)

or_plot=ggplot(results_odds, aes(x = as.factor(percentile), y = estimate, color)) +
        geom_point(stat = "identity", size=3,color = "black") +
        geom_hline(yintercept = 1, linetype = "dashed", color = "grey") +
        geom_errorbar(aes(ymin = estimate - se, ymax = estimate + se), width = 0.4) +
        ggtitle("Odds Ratio in 1st to 10th PRS score") +
        xlab("PRS Decile") +
        ylab("Odds")

ggsave(or_plot,file=tmp_or_plot,height = 8,width  = 8)

### Distribution plot ###

tmp_dist_plot<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.distribution.png',collapse = '')

#png(tmp_dist_plot,height = 500,width  = 500)

dist_plot=ggplot(PRS.pheno.plot, aes(x=SCORE, fill=Pheno)) +
        geom_vline(aes(xintercept=high10_line), colour="#BB0000", linetype="dashed")+
        geom_vline(aes(xintercept=low10_line), colour="#BB0000", linetype="dashed")+
        geom_text(aes(x = high10_line,y=0.4,label = "High 10% PRS"))+
        geom_text(aes(x = low10_line,y=0.4,label = "Low 10% PRS"))+
        geom_density(alpha=0.4, position = 'identity',bins=50)
ggsave(dist_plot,file=tmp_dist_plot,height = 8,width  = 8)

### Quantiles plot ###

tmp_quant_plot<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.quantiles.png',collapse = '')

#png(tmp_quant_plot,height = 500,width  = 500)

quant_plot=PRS.pheno.plot %>%
        count(percentile, Pheno) %>%       
        group_by(percentile) %>%
        mutate(pct= prop.table(n) * 100) %>%
        ggplot() + aes(percentile, pct, fill=Pheno) +
        geom_bar(stat="identity") +
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
  tmp_t_test<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.T-test.txt',collapse = '')
  fwrite(t.test.result,tmp_t_test,sep="\t",col.names = T)

# Wilcoxon Whitney U test , specify alternative="less"
  u.test.result<-tidy(wilcox.test(case$SCORE,ctrl$SCORE,alternative = "two.sided", paired = FALSE, exact = FALSE, correct = TRUE))
  cat('\nP-value of PRS Case/Control distribution U-test is:',u.test.result$p.value)
  cat('\n')
  cat('\n')
  tmp_u_test<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.U-test.txt',collapse = '')
  fwrite(u.test.result,tmp_u_test,sep="\t",col.names = T)

# Wasserstein distence test
cat('\n')
cat('Wasserstein distance is:',wasserstein1d(case$SCORE,ctrl$SCORE))
cat('\n')
tmp_Wass_test<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.Wasserstein-test.txt',collapse = '')
cat('Wasserstein distance is:',wasserstein1d(case$SCORE,ctrl$SCORE),sep = "\t", file = tmp_Wass_test)
  

################# Table 1 of PRS Sample in GLM model (Dropped NAs) #################

  cat('##### Table 1 of PRS Sample in GLM model (Dropped NAs) #####')
  cat('\n')
  cat('\n')

  table_PRS=PRS.pheno.plot
  cov = c('Pheno','Sex','Age')
  
  table_PRS_print <- table_PRS %>% select(cov)

  tmp_PRS_table1<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.table1.html',collapse = '')
  
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

# Ready GLM PRS Model Data

PRS.pheno.model=Prsice.pheno.model
colnames(PRS.pheno.model)<-c("FID","IID","SCORE","Sex","Age","Pheno")

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

tmp.tarin.data<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.AUC.train-data.txt',collapse = '')
fwrite(PRS.train.pheno,tmp.tarin.data,sep="\t",col.names=T)

tmp.test.data<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.AUC.test-data.txt',collapse = '')
fwrite(PRS.test.pheno,tmp.test.data,sep="\t",col.names=T)


# Read GLM PRS Model Data

mod_1 <- glm( Pheno ~ Sex+Age, data=PRS.train.pheno, family="binomial")
mod_2 <- glm( Pheno ~ SCORE, data=PRS.train.pheno, family="binomial")
mod_3 <- glm( Pheno ~ Sex+Age+SCORE, data=PRS.train.pheno, family="binomial")


##################################### Model 1 (Base only) #####################################

library(pROC)

# Get probability of model
train_1_prob = predict(mod_1, data=PRS.train.pheno ,type='response')

# Get threshold of probability for calssification
threshold_train_1 <- roc(response=PRS.train.pheno$Pheno, predictor=train_1_prob)
threshold_train_1_df <-coords(threshold_train_1, "best","threshold",best.method = "youden")

# Make prediction of classification
train_1_result = ifelse(train_1_prob > threshold_train_1_df$threshold,2,1)

# Making table on the train set.
train_1_tab = table(predicted = train_1_result, actual = PRS.train.pheno$Pheno)

# Calculate ROC 
train_1_roc = roc(PRS.train.pheno$Pheno ~ train_1_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

## Predicting Test Data
test_1_prob = predict(mod_1,newdata=PRS.test.pheno,type='response')

# Get threshold of probability for calssification
threshold_test_1 <- roc(response=PRS.test.pheno$Pheno, predictor=test_1_prob)
threshold_test_1_df <-coords(threshold_test_1, "best", best.method = "youden")

test_1_result = ifelse(test_1_prob > threshold_test_1_df$threshold,2,1)

## Plot
test_1_prob = predict(mod_1, newdata = PRS.test.pheno, type = "response")
test_1_roc = roc(PRS.test.pheno$Pheno ~ test_1_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)


##################################### Model 2 (PRS only) #####################################

library(pROC)

# Get probability of model
train_2_prob = predict(mod_2, data=PRS.train.pheno ,type='response')

# Get threshold of probability for calssification
threshold_train_2 <- roc(response=PRS.train.pheno$Pheno, predictor=train_2_prob)
threshold_train_2_df <-coords(threshold_train_2, "best", best.method = "youden")

# Make prediction of classification
train_2_result = ifelse(train_2_prob > threshold_train_2_df$threshold,2,1)

# Making table on the train set.
train_2_tab = table(predicted = train_2_result, actual = PRS.train.pheno$Pheno)

# Calculate ROC 
train_2_roc = roc(PRS.train.pheno$Pheno ~ train_2_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

# Predicting Test Data
test_2_prob = predict(mod_2,newdata=PRS.test.pheno,type='response')

# Get threshold of probability for calssification
threshold_test_2 <- roc(response=PRS.test.pheno$Pheno, predictor=test_2_prob)
threshold_test_2_df <-coords(threshold_test_2, "best", best.method = "youden")

test_2_result = ifelse(test_2_prob > threshold_test_2_df$threshold,2,1)

## Plot
test_2_prob = predict(mod_2, newdata = PRS.test.pheno, type = "response")
test_2_roc = roc(PRS.test.pheno$Pheno ~ test_2_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

##################################### Model 3 Base + PRS ####################################

library(pROC)


# Get probability of model
train_3_prob = predict(mod_3, data=PRS.train.pheno ,type='response')

# Get threshold of probability for calssification
threshold_train_3 <- roc(response=PRS.train.pheno$Pheno, predictor=train_3_prob)
threshold_train_3_df <-coords(threshold_train_3, "best", best.method = "youden")

# Make prediction of classification
train_3_result = ifelse(train_3_prob > threshold_train_3_df$threshold,2,1)

# Making table on the train set.
train_3_tab = table(predicted = train_3_result, actual = PRS.train.pheno$Pheno)

# Calculate ROC 
train_3_roc = roc(PRS.train.pheno$Pheno ~ train_3_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

## Predicting Test Data
test_3_prob = predict(mod_3,newdata=PRS.test.pheno,type='response')

# Get threshold of probability for calssification
threshold_test_3 <- roc(response=PRS.test.pheno$Pheno, predictor=test_3_prob)
threshold_test_3_df <-coords(threshold_test_3, "best", best.method = "youden")

test_3_result = ifelse(test_3_prob > threshold_test_3_df$threshold,2,1)

## Plot
test_3_prob = predict(mod_3, newdata = PRS.test.pheno, type = "response")
test_3_roc = roc(PRS.test.pheno$Pheno ~ test_3_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

###################################### Three model AUCs #####################################
cat('\n')
cat('(Train) AUC of Base Model is:', auc(train_1_roc))
cat('\n')
cat('\n(Train) AUC of PRS Model is:', auc(train_2_roc))
cat('\n')
cat('\n(Train) AUC of Base + PRS Model is:', auc(train_3_roc))
cat('\n')
cat('\n(Test) AUC of Base Model is:', auc(test_1_roc))
cat('\n')
cat('\n(Test) AUC of PRS Model is:', auc(test_2_roc))
cat('\n')
cat('\n(Test) AUC of Base + PRS Model is:', auc(test_3_roc))
cat('\n')
cat('\n')
cat('\n')
### Model plot ###

tmp_model_plot<-paste0('./Result/',Project,'/PRS/plot/',PLOT_OUT,'.AUCs.png',collapse = '')

png(tmp_model_plot,height = 500,width  = 500)

test_1_roc = roc(PRS.test.pheno$Pheno ~ test_1_prob)
test_2_roc = roc(PRS.test.pheno$Pheno ~ test_2_prob)
test_3_roc = roc(PRS.test.pheno$Pheno ~ test_3_prob)

plot(test_1_roc,print.auc = TRUE, print.auc.y = .4)
plot(test_2_roc,print.auc = TRUE, print.auc.y = .3 ,add=TRUE, col='red',)
plot(test_3_roc,print.auc = TRUE, print.auc.y = .2 ,add=TRUE, col='blue')

text(0.15, .4, paste("Base Model"))
text(0.15, .3, paste("PRS Model"))
text(0.15, .2, paste("Base Model + PRS"))
cat('\n')
cat('AUC of Base Model is:', auc(test_1_roc))
cat('\n')
cat('\nAUC of PRS Model is:', auc(test_2_roc))
cat('\n')
cat('\nAUC of Base Model+PRS is:', auc(test_3_roc))
cat('\n')
cat('\n')
dev.off()
cat('\n')
cat('############# All PRS Analysis and plot successfully !!! ########')
cat('\n')
cat('\n')
