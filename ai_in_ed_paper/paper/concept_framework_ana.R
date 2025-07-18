# ฟังก์ชันคำนวณ geometric median สำหรับ 2D
geometric_median_2d <- function(x, y, max_iter = 100, tol = 1e-6) {
  # ตรวจสอบ input
  if (length(x) != length(y)) {
    stop("x and y must have the same length")
  }
  
  if (length(x) < 2) {
    return(c(x[1], y[1]))
  }
  
  # สร้าง points matrix
  points <- cbind(x, y)
  
  # เริ่มต้นด้วย median
  current <- c(median(x), median(y))
  
  for (i in 1:max_iter) {
    # คำนวณ distances จาก current point ไปยังจุดต่างๆ
    distances <- sqrt((points[, 1] - current[1])^2 + (points[, 2] - current[2])^2)
    
    # หลีกเลี่ยง division by zero
    distances[distances < tol] <- tol
    
    # คำนวณ weights
    weights <- 1 / distances
    weights <- weights / sum(weights)
    
    # Update centroid
    new_centroid <- c(
      sum(weights * points[, 1]),
      sum(weights * points[, 2])
    )
    
    # Check convergence
    if (sqrt(sum((new_centroid - current)^2)) < tol) break
    
    current <- new_centroid
  }
  
  return(current)
}

# ฟังก์ชันหลักสำหรับหาคำที่อยู่ใกล้ centroid ของแต่ละ category
find_centroid_keywords <- function(df, embedding_df, umap_df, n_closest = 5, method = "embedding", centroid_type = "geometric") {
  library(tidyverse)
  library(lsa)
  
  # รวมข้อมูลทั้งหมด
  data_combined <- df %>% 
    bind_cols(umap_df) %>%
    mutate(keyword_clean = keyword)
  
  # สร้าง list เก็บผลลัพธ์
  results <- list()
  
  # วนลูปแต่ละ category
  for (cat in unique(data_combined$category)) {
    cat_data <- data_combined %>% filter(category == cat)
    
    if (method == "embedding") {
      # ใช้ original embeddings (384 มิติ)
      cat_embeddings <- embedding_df[rownames(embedding_df) %in% cat_data$keyword, ]
      
      # เลือกประเภท centroid
      if (centroid_type == "geometric") {
        # ใช้ median แทน geometric median สำหรับ high-dimensional space
        # (geometric median ใน high-dim ซับซ้อนกว่า)
        centroid <- apply(cat_embeddings, 2, median)
      } else {
        centroid <- colMeans(cat_embeddings)
      }
      
      # คำนวณ cosine similarity กับ centroid
      similarities <- apply(cat_embeddings, 1, function(x) {
        lsa::cosine(x, centroid)
      })
      
    } else if (method == "umap") {
      # ใช้ UMAP coordinates (2 มิติ)
      if (centroid_type == "geometric") {
        geom_centroid <- geometric_median_2d(cat_data$UMAP1, cat_data$UMAP2)
        centroid_umap1 <- geom_centroid[1]
        centroid_umap2 <- geom_centroid[2]
      } else {
        centroid_umap1 <- mean(cat_data$UMAP1)
        centroid_umap2 <- mean(cat_data$UMAP2)
      }
      
      # คำนวณ Euclidean distance ใน UMAP space
      distances <- sqrt((cat_data$UMAP1 - centroid_umap1)^2 + 
                          (cat_data$UMAP2 - centroid_umap2)^2)
      
      # แปลงเป็น similarity (ยิ่งใกล้ยิ่งสูง)
      similarities <- 1 / (1 + distances)
      names(similarities) <- cat_data$keyword
    }
    
    # เรียงลำดับและเลือก n_closest อันดับแรก
    top_keywords <- names(sort(similarities, decreasing = TRUE))[1:min(n_closest, length(similarities))]
    top_scores <- sort(similarities, decreasing = TRUE)[1:min(n_closest, length(similarities))]
    
    # เก็บผลลัพธ์
    results[[cat]] <- list(
      category = cat,
      centroid_keywords = top_keywords,
      similarity_scores = top_scores,
      total_keywords = nrow(cat_data),
      centroid_type = centroid_type
    )
  }
  
  return(results)
}

# ฟังก์ชันสำหรับแสดงผลลัพธ์แบบสวยงาม
display_centroid_results <- function(centroid_results) {
  cat("=== Central Keywords Analysis ===\n\n")
  
  for (i in 1:length(centroid_results)) {
    result <- centroid_results[[i]]
    
    cat("Category:", result$category, "\n")
    cat("Centroid type:", result$centroid_type, "\n")
    cat("Total keywords:", result$total_keywords, "\n")
    cat("Top central keywords:\n")
    
    for (j in 1:length(result$centroid_keywords)) {
      cat(sprintf("  %d. %s (similarity: %.3f)\n", 
                  j, 
                  result$centroid_keywords[j], 
                  result$similarity_scores[j]))
    }
    cat("\n")
  }
}

# ฟังก์ชันสำหรับสร้างตารางสรุป
create_centroid_summary_table <- function(centroid_results) {
  library(tibble)
  
  summary_df <- map_dfr(centroid_results, function(result) {
    tibble(
      category = result$category,
      centroid_type = result$centroid_type,
      most_central = result$centroid_keywords[1],
      second_central = ifelse(length(result$centroid_keywords) >= 2, 
                              result$centroid_keywords[2], NA),
      third_central = ifelse(length(result$centroid_keywords) >= 3, 
                             result$centroid_keywords[3], NA),
      highest_similarity = round(result$similarity_scores[1], 3),
      total_keywords = result$total_keywords
    )
  })
  
  return(summary_df)
}

# ฟังก์ชันสำหรับสร้างภาพแสดง centroid
plot_centroids_with_keywords <- function(df, umap_df, centroid_results, top_n = 3) {
  library(ggplot2)
  library(ggrepel)
  
  # รวมข้อมูล
  data_plot <- df %>% 
    bind_cols(umap_df) %>%
    mutate(is_central = FALSE)
  
  # ทำเครื่องหมายคำที่เป็น central
  for (result in centroid_results) {
    central_keywords <- result$centroid_keywords[1:min(top_n, length(result$centroid_keywords))]
    data_plot$is_central[data_plot$keyword %in% central_keywords] <- TRUE
  }
  
  # คำนวณ centroid positions ด้วย geometric median
  centroid_positions <- df %>% 
    bind_cols(umap_df) %>%
    group_by(category) %>%
    summarise(
      centroid_coords = list(geometric_median_2d(UMAP1, UMAP2)),
      .groups = "drop"
    ) %>%
    mutate(
      centroid_x = map_dbl(centroid_coords, 1),
      centroid_y = map_dbl(centroid_coords, 2)
    ) %>%
    select(-centroid_coords)
  
  # สร้างกราฟ
  p <- data_plot %>%
    ggplot(aes(UMAP1, UMAP2)) +
    geom_point(aes(color = category, size = is_central, alpha = is_central)) +
    geom_text_repel(
      data = data_plot %>% filter(is_central),
      aes(label = keyword, color = category),
      size = 4,
      fontface = "bold",
      box.padding = 0.5,
      point.padding = 0.3
    ) +
    geom_point(
      data = centroid_positions,
      aes(x = centroid_x, y = centroid_y),
      shape = 4, size = 6, color = "black", stroke = 2
    ) +
    scale_size_manual(values = c(2, 4)) +
    scale_alpha_manual(values = c(0.6, 1)) +
    theme_minimal() +
    theme(legend.position = "bottom") +
    labs(
      title = "Keywords Near Category Centroids (Geometric Median)",
      subtitle = paste("Top", top_n, "central keywords highlighted for each category"),
      caption = "Black crosses mark geometric median centroids"
    )
  
  return(p)
}

# ฟังก์ชันเปรียบเทียบ mean vs geometric median centroids
compare_centroid_methods <- function(df, embedding_df, umap_df, n_closest = 5) {
  # หาด้วย embedding space
  geometric_results <- find_centroid_keywords(df, embedding_df, umap_df, 
                                              n_closest, method = "embedding", 
                                              centroid_type = "geometric")
  
  mean_results <- find_centroid_keywords(df, embedding_df, umap_df, 
                                         n_closest, method = "embedding", 
                                         centroid_type = "mean")
  
  # หาด้วย UMAP space  
  umap_geometric_results <- find_centroid_keywords(df, embedding_df, umap_df, 
                                                   n_closest, method = "umap", 
                                                   centroid_type = "geometric")
  
  umap_mean_results <- find_centroid_keywords(df, embedding_df, umap_df, 
                                              n_closest, method = "umap", 
                                              centroid_type = "mean")
  
  # เปรียบเทียบผลลัพธ์
  comparison <- map_dfr(names(geometric_results), function(cat) {
    geom_emb_top3 <- geometric_results[[cat]]$centroid_keywords[1:3]
    mean_emb_top3 <- mean_results[[cat]]$centroid_keywords[1:3]
    geom_umap_top3 <- umap_geometric_results[[cat]]$centroid_keywords[1:3]
    mean_umap_top3 <- umap_mean_results[[cat]]$centroid_keywords[1:3]
    
    tibble(
      category = cat,
      embedding_geometric_top1 = geom_emb_top3[1],
      embedding_mean_top1 = mean_emb_top3[1],
      umap_geometric_top1 = geom_umap_top3[1],
      umap_mean_top1 = mean_umap_top3[1],
      emb_overlap = length(intersect(geom_emb_top3, mean_emb_top3)),
      umap_overlap = length(intersect(geom_umap_top3, mean_umap_top3))
    )
  })
  
  return(list(
    embedding_geometric = geometric_results,
    embedding_mean = mean_results,
    umap_geometric = umap_geometric_results,
    umap_mean = umap_mean_results,
    comparison_table = comparison
  ))
}

# ฟังก์ชันสำหรับ export ผลลัพธ์เป็น concept framework
export_to_concept_framework <- function(centroid_results, method = "embedding") {
  framework <- map(centroid_results, function(result) {
    list(
      category = result$category,
      central_concept = result$centroid_keywords[1],
      supporting_concepts = result$centroid_keywords[-1],
      concept_strength = result$similarity_scores[1],
      analysis_method = method,
      centroid_type = result$centroid_type
    )
  }) %>% set_names(map_chr(centroid_results, ~.x$category))
  
  return(framework)
}

# ฟังก์ชันแสดงภาพเปรียบเทียบ centroids
plot_centroid_comparison <- function(df, umap_df) {
  library(ggplot2)
  library(tidyr)
  
  data_plot <- df %>% bind_cols(umap_df)
  
  # คำนวณ centroids หลายวิธี
  centroids_comparison <- data_plot %>%
    group_by(category) %>%
    summarise(
      # Mean
      mean_x = mean(UMAP1),
      mean_y = mean(UMAP2),
      
      # Median
      median_x = median(UMAP1),
      median_y = median(UMAP2),
      
      # Geometric median
      geom_coords = list(geometric_median_2d(UMAP1, UMAP2)),
      .groups = "drop"
    ) %>%
    mutate(
      geom_x = map_dbl(geom_coords, 1),
      geom_y = map_dbl(geom_coords, 2)
    ) %>%
    select(-geom_coords)
  
  # เตรียมข้อมูล centroids สำหรับ plot
  centroids_long <- centroids_comparison %>%
    pivot_longer(
      cols = c(mean_x, median_x, geom_x),
      names_to = "method",
      values_to = "x"
    ) %>%
    mutate(
      y = case_when(
        method == "mean_x" ~ mean_y,
        method == "median_x" ~ median_y,
        method == "geom_x" ~ geom_y
      ),
      method = str_remove(method, "_x")
    )
  
  # สร้างกราฟ
  p <- ggplot() +
    geom_point(data = data_plot, 
               aes(UMAP1, UMAP2, color = category), 
               alpha = 0.6, size = 2) +
    geom_point(data = centroids_long,
               aes(x, y, shape = method),
               size = 6, stroke = 2, fill = "white") +
    scale_shape_manual(values = c("mean" = 1, "median" = 4, "geom" = 2),
                       labels = c("mean" = "Mean", "median" = "Median", "geom" = "Geometric Median")) +
    facet_wrap(~category, scales = "free") +
    theme_minimal() +
    labs(
      title = "Comparison of Different Centroid Methods",
      subtitle = "O = Mean, X = Median, △ = Geometric Median",
      shape = "Centroid Method"
    ) +
    theme(legend.position = "bottom")
  
  return(p)
}


# ฟังก์ชันแก้ไขที่ปลอดภัย
plot_fixed_safe <- function(df, umap_df, top_n = 3) {
  library(ggplot2)
  library(ggrepel)
  
  # คำนวณใหม่จากข้อมูลดิบ
  data_combined <- df %>% bind_cols(umap_df)
  
  results <- list()
  
  # หาคำที่ใกล้ centroid ที่สุดสำหรับแต่ละ category
  for (cat in unique(data_combined$category)) {
    cat_data <- data_combined %>% filter(category == cat)
    
    # คำนวณ geometric median centroid
    centroid_coords <- geometric_median_2d(cat_data$UMAP1, cat_data$UMAP2)
    
    # คำนวณระยะห่าง
    cat_data <- cat_data %>%
      mutate(
        distance_to_centroid = sqrt((UMAP1 - centroid_coords[1])^2 + 
                                      (UMAP2 - centroid_coords[2])^2)
      ) %>%
      arrange(distance_to_centroid)
    
    # เลือก top_n คำที่ใกล้ที่สุด
    selected_words <- cat_data[1:min(top_n, nrow(cat_data)), ]
    
    results[[cat]] <- list(
      category = cat,
      centroid_x = centroid_coords[1],
      centroid_y = centroid_coords[2],
      selected_words = selected_words
    )
  }
  
  # เตรียมข้อมูลสำหรับ plot
  plot_data <- data_combined %>%
    mutate(is_selected = FALSE, rank = NA)
  
  centroids_df <- map_dfr(results, function(r) {
    tibble(
      category = r$category,
      centroid_x = r$centroid_x,
      centroid_y = r$centroid_y
    )
  })
  
  selected_words_df <- map_dfr(results, function(r) {
    r$selected_words %>%
      mutate(rank = row_number()) %>%
      select(category, keyword, UMAP1, UMAP2, distance_to_centroid, rank)
  })
  
  # ทำเครื่องหมายคำที่เลือก
  for (i in 1:nrow(selected_words_df)) {
    word_idx <- which(plot_data$keyword == selected_words_df$keyword[i])
    if (length(word_idx) > 0) {
      plot_data$is_selected[word_idx] <- TRUE
      plot_data$rank[word_idx] <- selected_words_df$rank[i]
    }
  }
  
  # สร้างกราฟ
  p <- ggplot() +
    # จุดทั้งหมด
    geom_point(data = plot_data, 
               aes(UMAP1, UMAP2, color = category), 
               alpha = 0.4, size = 2) +
    # Centroids
    geom_point(data = centroids_df,
               aes(x = centroid_x, y = centroid_y),
               shape = 4, size = 10, color = "black", stroke = 3) +
    # คำที่เลือก
    geom_point(data = plot_data %>% filter(is_selected),
               aes(UMAP1, UMAP2, color = category, size = factor(rank)), 
               alpha = 1) +
    # ป้ายชื่อ
    geom_text_repel(
      data = plot_data %>% filter(is_selected),
      aes(UMAP1, UMAP2, 
          label = paste0(rank, ". ", keyword), 
          color = category),
      size = 3.5, fontface = "bold",
      box.padding = 0.5, point.padding = 0.3,
      max.overlaps = 20
    ) +
    # เส้นเชื่อม
    geom_segment(
      data = selected_words_df %>% 
        left_join(centroids_df, by = "category"),
      aes(x = centroid_x, y = centroid_y, 
          xend = UMAP1, yend = UMAP2, color = category),
      linetype = "dashed", alpha = 0.7, linewidth = 0.8
    ) +
    scale_size_manual(values = c("1" = 6, "2" = 5, "3" = 4)) +
    theme_minimal() +
    theme(legend.position = "bottom") +
    labs(
      title = "Keywords Actually Closest to Geometric Median Centroids",
      subtitle = paste("Top", top_n, "closest keywords verified by distance calculation"),
      caption = "Black X = geometric median centroids, dashed lines = actual closest connections",
      size = "Distance Rank"
    )
  
  # แสดงข้อมูลการตรวจสอบ
  cat("=== Verification: Words closest to centroids ===\n")
  verification_summary <- selected_words_df %>%
    select(category, rank, keyword, distance_to_centroid) %>%
    arrange(category, rank)
  
  print(verification_summary)
  
  return(p)
}
