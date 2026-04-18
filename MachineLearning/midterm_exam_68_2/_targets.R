library(targets)
tar_source("R")
tar_option_set(packages = c("tidyverse", "tidymodels", "embed", "future"))

list(
  ## 01. Data Importing and Cleaning
  tar_target(file, "data/onlinelearning_miss.csv", format = "file"),
  tar_target(raw_data, importing_data(file)),
  tar_target(cleaned_data, clean_data(raw_data)),
  tar_target(na_outcome_rm,
    cleaned_data |> 
      drop_na(outcome_online)
  ),
  ## 02. Data Splitting 
  tar_target(data_split, initial_split(na_outcome_rm, prop = 0.8, strata = outcome_online)),
  tar_target(train_data, training(data_split)),
  tar_target(test_data, testing(data_split)),
  ## 03. Data Preprocessing
  tar_target(base_recipe, 
    recipe(outcome_online ~ ., data = train_data) |>
      step_rm(student_id) |>
      step_lencode_glm(all_nominal_predictors(), outcome = "outcome_online") |> 
      step_impute_bag(all_numeric_predictors()) |> 
      step_normalize(all_numeric_predictors())
  ),
  ## 04. Model Specification
  tar_target(regression_spec,
    reg_spec <- linear_reg(penalty = tune()) |> 
      set_engine("glmnet") |> 
      set_mode("regression")
  ),
  tar_target(random_forest_spec,
    rf_spec <- rand_forest(mtry = tune(), min_n = tune()) |> 
      set_engine("ranger") |> 
      set_mode("regression")
  ),
  ## 05. Model Tuning
  tar_target(workflowset,
    wfls <- workflow_set(
      preproc = list(baserec = base_recipe),
      models = list(reg = regression_spec, rf = random_forest_spec)
    )),
  tar_target(vfold_split,
    {
    set.seed(123)
    vfold <- vfold_cv(train_data, v = 5, strata = outcome_online)
    }
  ),
  tar_target(tune_wfset,
    {
    plan(multisession, workers = 13)
    tuned_wfset <- workflow_map(
        workflowset,
        "tune_grid",
        grid = 10,
        resamples = vfold_split,
        control = control_grid(save_pred = TRUE,
        verbose = TRUE,
        parallel_over = "resamples")
    )
    plan(sequential)
    tuned_wfset ## target จะเอา object ตัวสุดท้ายของ code ไปเป็นไว้
    }
  ),
  tar_target(autoplot,
    autoplot(tune_wfset) + theme_light()
      ),
  tar_target(best_model,
    {
   best_reg <- tune_wfset |> 
      extract_workflow_set_result("baserec_reg") |> 
      select_by_one_std_err(metric = "rmse", penalty)

   best_rf <- tune_wfset |>
      extract_workflow_set_result("baserec_rf") |> 
      select_by_one_std_err(metric = "rmse", min_n)
    
   best <- tibble(
     model = c("regression", "random_forest"),
     best_result = list(best_reg, best_rf)
   )

    }
  ),
  tar_target(final_model,
    {
    final_reg <- finalize_workflow(
      workflowset |> extract_workflow("baserec_reg"),
      best_model$best_result[[1]]
    ) |> 
      fit(train_data)

    final_rf <- finalize_workflow(
      workflowset |> extract_workflow("baserec_rf"),
      best_model$best_result[[2]]
    ) |> 
      fit(train_data)

    final_models <- list(regression = final_reg, random_forest = final_rf)
    }
  ),
  tar_target(test_results,
    {
    reg_pred <- predict(final_model$regression, test_data) |> 
      bind_cols(test_data |> select(outcome_online)) |> 
      rename(pred_reg = .pred)

    rf_pred <- predict(final_model$random_forest, test_data) |> 
      bind_cols(test_data |> select(outcome_online)) |> 
      rename(pred_rf = .pred)

    test_results <- reg_pred |> 
      left_join(rf_pred, by = "outcome_online")
    }
  ),
  tar_target(plot_test,
  test_results |> 
    pivot_longer(cols = starts_with("pred"), names_to = "model", values_to = "prediction") |> 
    ggplot(aes(x = outcome_online, y = prediction, color = model)) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    labs(title = "Predicted vs Actual Values",
         x = "Actual Outcome Online",
         y = "Predicted Outcome Online") +
    theme_light()
)
)
