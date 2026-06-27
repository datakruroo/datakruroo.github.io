library(dplyr)
library(tibble)
library(cluster)

fit_eval_hclust <- function(x, distance, linkage, k) {
  d <- dist(x, method = distance)

  hc <- hclust(d, method = linkage)

  cl <- cutree(hc, k = k)

  sil <- cluster::silhouette(cl, d)

  sil_width <- sil[, "sil_width"]
  cluster_size <- table(cl)

  tibble(
    distance = distance,
    linkage = linkage,
    k = k,
    silhouette_avg = mean(sil_width),
    silhouette_min = min(sil_width),
    silhouette_median = median(sil_width),
    prop_negative_silhouette = mean(sil_width < 0),
    min_cluster_size = min(cluster_size),
    max_cluster_size = max(cluster_size),
    cluster_size_ratio = max(cluster_size) / min(cluster_size)
  )
}

profile_clusters <- function(data, cluster) {
  data |>
    mutate(.cluster = factor(cluster)) |>
    mutate(across(where(is.numeric), scale)) |>
    group_by(.cluster) |>
    summarise(
      across(
        where(is.numeric),
        ~ mean(.x, na.rm = TRUE)
      ),
      .groups = "drop"
    )
}