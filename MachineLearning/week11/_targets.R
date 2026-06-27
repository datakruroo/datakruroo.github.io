library(targets)

tar_option_set(
  packages = c(
    "tidyverse",
    "recipes",
    "rsample",
    "cluster",
    "tibble"
  )
)

source("R/01_hclust_helper.R")
list(

  # 1. Load data -------------------------------------------------------------

  tar_target(
    raw_data,
    read_csv("clustering_data.csv")
  ),

  # 2. Select variables for clustering --------------------------------------
  # เก็บ gpa ไว้ใน raw_data ได้ แต่ตัดออกจาก x_clust เพื่อไม่ให้ใช้สร้าง cluster

  tar_target(
    x_clust,
    raw_data |>
      dplyr::select(-student_id)
  ),

  # 3. Preprocess data -------------------------------------------------------

  tar_target(
    rec_clust,
    recipes::recipe(~ ., data = x_clust) |>
      recipes::step_impute_knn(recipes::all_numeric_predictors()) |>
      recipes::step_normalize(recipes::all_numeric_predictors())
  ),

  # 4. Resampling ------------------------------------------------------------
  # ต้อง resample จาก data frame ไม่ใช่ recipe

  tar_target(
    folds,
    rsample::vfold_cv(
      x_clust,
      v = 5,
      repeats = 2
    )
  ),

  # 5. Parameter grid --------------------------------------------------------

  tar_target(
    param_grid,
    tidyr::expand_grid(
      distance = c("euclidean", "manhattan"),
      linkage = c("complete", "average"),
      k = 2:8
    )
  ),

  # 6. Fit and evaluate across resamples ------------------------------------

  tar_target(
    metric_results,
    purrr::map_dfr(
      folds$splits,
      function(split) {

        analysis_data <- rsample::analysis(split)

        x_processed <- rec_clust |>
          recipes::prep(training = analysis_data) |>
          recipes::bake(new_data = analysis_data)

        purrr::pmap_dfr(
          param_grid,
          function(distance, linkage, k) {
            fit_eval_hclust(
              x = x_processed,
              distance = distance,
              linkage = linkage,
              k = k
            )
          }
        )
      },
      .id = "fold_id"
    )
  ),

  # 7. Summarise metrics -----------------------------------------------------

  tar_target(
    metric_summary,
    metric_results |>
      dplyr::group_by(distance, linkage, k) |>
      dplyr::summarise(
        mean_silhouette = mean(silhouette_avg, na.rm = TRUE),
        sd_silhouette = sd(silhouette_avg, na.rm = TRUE),
        mean_prop_negative = mean(prop_negative_silhouette, na.rm = TRUE),
        mean_min_cluster_size = mean(min_cluster_size, na.rm = TRUE),
        mean_cluster_size_ratio = mean(cluster_size_ratio, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::arrange(
        dplyr::desc(mean_silhouette),
        mean_prop_negative,
        sd_silhouette
      )
  ),

  # 8. Select best/candidate solution ---------------------------------------

  tar_target(
    best_solution,
    metric_summary |>
      dplyr::filter(mean_min_cluster_size >= 5) |>
      dplyr::slice(1)
  ),

  # 9. Final preprocessing on full data -------------------------------------

  tar_target(
    x_final,
    rec_clust |>
      recipes::prep(training = x_clust) |>
      recipes::bake(new_data = x_clust)
  ),

  # 10. Fit final hierarchical clustering -----------------------------------

  tar_target(
    final_dist,
    stats::dist(
      x_final,
      method = best_solution$distance
    )
  ),

  tar_target(
    final_hclust,
    stats::hclust(
      final_dist,
      method = best_solution$linkage
    )
  ),

  tar_target(
    final_cluster,
    stats::cutree(
      final_hclust,
      k = best_solution$k
    )
  ),

  # 11. Final silhouette -----------------------------------------------------

  tar_target(
    final_silhouette,
    cluster::silhouette(
      final_cluster,
      final_dist
    )
  ),

  tar_target(
    final_silhouette_summary,
    tibble::tibble(
      silhouette_avg = mean(final_silhouette[, "sil_width"], na.rm = TRUE),
      silhouette_min = min(final_silhouette[, "sil_width"], na.rm = TRUE),
      prop_negative_silhouette = mean(final_silhouette[, "sil_width"] < 0, na.rm = TRUE)
    )
  ),

  # 12. Cluster profile ------------------------------------------------------
  # profile ใช้เฉพาะตัวแปร clustering ไม่รวม gpa

  tar_target(
    cluster_profile,
    profile_clusters(
      data = x_clust,
      cluster = final_cluster
    )
  ),

  tar_target(
    cluster_profile_long,
    cluster_profile |>
      tidyr::pivot_longer(
        cols = -.cluster,
        names_to = "variable",
        values_to = "z_mean"
      )
  )

  # 13. External description with GPA ----------------------------------------
  # อันนี้ไม่ใช้สร้าง cluster แต่ใช้ตรวจว่า cluster สัมพันธ์กับ GPA ไหม

 
)