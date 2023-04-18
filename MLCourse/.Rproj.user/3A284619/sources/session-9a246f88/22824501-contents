dat<-read.csv("/Users/siwachoat/Library/CloudStorage/OneDrive-ChulalongkornUniversity/Documents/ML/MLcourse/MLCourse/homeworks/xAPI-Edu-Data.csv")




library(partykit)
library(mlbench)

# Load the Sonar dataset (a binary classification problem)
data(Sonar)
X <- Sonar[, 1:60]
y <- Sonar$Class

# Create a grouping variable (in this example, we use the first 30 rows as one group and the remaining rows as another group)
groups <- rep(c(1, 2), c(30, nrow(X)-30))

logit <- function(y, x, start = NULL, weights = NULL, offset = NULL, ...) {
  glm(y ~ 0 + x, family = binomial, start = start, ...)
}
# Fit a multilevel decision tree
tree <- mob(y ~ . | groups, data = cbind(X, y), fit=logit)

# Visualize the tree
plot(tree, tp_args = list(id = FALSE))


my_data<-temp1
data_subset <- data.frame(var1 = my_data$var1, var2 = my_data$var2, var3 = my_data$var3)






dat_na <- dat_preproc%>%bind_shadow() %>%
  dplyr::select(school:Ach, 
                PreTest_NA, traveltime_NA, fam_relation_NA) %>%
  mutate(MomEdu = factor(MomEdu, levels=c(0,1,2,3,4),
                         labels=c("none","primary","highsch1","highsch2","grad")),
         DadEdi = factor(DadEdi, levels=c(0,1,2,3,4),
                         labels=c("none","primary","highsch1","highsch2","grad")),
         traveltime = factor(traveltime, levels=c(1,2,3,4),
                             labels=c("<15mins",
                                      "15-30mins",
                                      "30-60mins",
                                      ">60mins")),
         readingtime = factor(readingtime, levels=c(1,2,3,4),
                              labels=c("<2hours",
                                       "2-5hours",
                                       "5-10hours",
                                       ">10hours")),
         fam_relation = factor(fam_relation, levels=c(1,2,3,4,5),
                               labels=c("worst",
                                        "bad",
                                        "fair",
                                        "good",
                                        "very good")),
         freetime = factor(freetime, levels=c(1,2,3,4,5),
                           labels=c("very little",
                                    "litter",
                                    "moderate",
                                    "high",
                                    "highest")),
         goout = factor(goout, levels=c(1,2,3,4,5),
                        labels=c("very little",
                                 "litter",
                                 "moderate",
                                 "high",
                                 "highest")),
         Drink_alc = factor(Drink_alc, levels=c(1,2,3,4,5),
                            labels=c("very little",
                                     "litter",
                                     "moderate",
                                     "high",
                                     "highest")),
         health = factor(health, levels=c(1,2,3,4,5),
                         labels=c("worst",
                                  "bad",
                                  "fair",
                                  "good",
                                  "very good"))
  )






# defined preprocess
rec1 <- recipe(PreTest_NA ~., data=dat_na) %>%
  step_rm(traveltime_NA,fam_relation_NA, PreTest) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors())
rec2 <- recipe(traveltime_NA ~., data=dat_na) %>%
  step_rm(PreTest_NA, fam_relation_NA, traveltime) %>%
  step_normalize(all_numeric_predictors())%>%
  step_dummy(all_nominal_predictors())
rec3<- recipe(fam_relation_NA ~., data=dat_na) %>%
  step_rm(PreTest_NA, traveltime_NA, fam_relation) %>%
  step_normalize(all_numeric_predictors())%>%
  step_dummy(all_nominal_predictors())
# defined model
logistic_mod <- logistic_reg(penalty = tune(),
                             mixture = tune()) %>%
  set_engine("glmnet") %>%
  set_mode("classification")
# defined workflow
folds<-vfold_cv(data = dat_na, v=10)

na_workflow1 <- workflow() %>%
  add_recipe(rec1) %>%
  add_model(logistic_mod) %>%
  tune_grid(resamples = folds)
library(doMC)
registerDoMC(cores=15)
result_na <- na_workflowset %>%
  workflow_map(resamples = folds,
               grid=50)


####

library(recipes)
dat1<-read.csv("/Users/siwachoat/Downloads/student-por.csv")
dat2<-read.csv("/Users/siwachoat/Downloads/student-mat (1).csv")

rec<-recipe(G3~., data=dat1) %>%
  step_select(-G2, -reason, -paid, -famsup, -Walc) %>%
  step_mutate(school = ifelse(school=="GP","obec.sec","obec.pri"),
              age = age -4
  ) %>%
  step_rename("gender" = "sex", 
              "location" = "address",
              "ParentStat" = "Pstatus",
              "MomEdu" = "Medu",
              "DadEdi" = "Fedu",
              "MomJob" = "Mjob",
              "DadJob" = "Fjob",
              "StuParent" = "guardian",
              "readingtime" = "studytime",
              "fail" = "failures",
              "scholarship" = "schoolsup",
              "club_act" = "activities",
              "InLove" = "romantic",
              "fam_relation" = "famrel",
              "Drink_alc" = "Dalc",
              "PreTest" = "G1",
              "Ach" = "G3"
  ) %>%
  prep(NULL) %>%
  juice()
write.csv(rec, file="Eng.csv", row.names=F)
write.csv(rec, file="Math.csv", row.names=F)


