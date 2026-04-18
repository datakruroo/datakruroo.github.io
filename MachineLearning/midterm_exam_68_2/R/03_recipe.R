data_preprocessing_recipe <- function(train_data) {

rec <- recipe(outcome_online ~ ., data = train_data) |>
  step_rm(student_id) |>
  step_lencode_glm(all_nominal_predictors(), outcome = "outcome_online") |> 
  step_normalize(all_numeric_predictors()) |>
  step_impute_knn(all_numeric_predictors())
  
return(rec)
}
  