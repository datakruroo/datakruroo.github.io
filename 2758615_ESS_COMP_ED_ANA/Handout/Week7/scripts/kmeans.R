# K-means Clustering Visualization for Educational Purpose
# โปรแกรมนี้ประกอบด้วย 4 ฟังก์ชันหลัก:
# 1. generate_sample_data() - สร้างข้อมูลตัวอย่าง
# 2. kmeans_step() - ทำ K-means แต่ละ iteration
# 3. plot_kmeans_step() - วาดภาพแต่ละขั้นตอน
# 4. create_kmeans_tutorial() - รวมทุกอย่างเป็นสื่อการเรียนรู้

library(tidyverse)
library(patchwork)  # สำหรับจัดเรียง plots
library(scales)     # สำหรับ color palette

# ฟังก์ชันที่ 1: สร้างข้อมูลตัวอย่าง
generate_sample_data <- function(seed = 123) {
  set.seed(seed)
  
  # สร้าง 3 กลุ่มข้อมูล
  group1 <- tibble(x = rnorm(20, 2, 0.5), y = rnorm(20, 2, 0.5))
  group2 <- tibble(x = rnorm(20, 5, 0.5), y = rnorm(20, 6, 0.5))
  group3 <- tibble(x = rnorm(20, 8, 0.5), y = rnorm(20, 3, 0.5))
  
  bind_rows(group1, group2, group3) %>%
    mutate(point_id = row_number())
}

# ฟังก์ชันที่ 2: คำนวณ K-means แต่ละขั้นตอน
kmeans_step <- function(data, centroids, step_type = "assign") {
  if (step_type == "assign") {
    # กำหนด cluster ให้แต่ละจุด
    data %>%
      rowwise() %>%
      mutate(
        dist_to_c1 = sqrt((x - centroids$x[1])^2 + (y - centroids$y[1])^2),
        dist_to_c2 = sqrt((x - centroids$x[2])^2 + (y - centroids$y[2])^2),
        dist_to_c3 = sqrt((x - centroids$x[3])^2 + (y - centroids$y[3])^2),
        cluster = case_when(
          dist_to_c1 <= dist_to_c2 & dist_to_c1 <= dist_to_c3 ~ 1,
          dist_to_c2 <= dist_to_c1 & dist_to_c2 <= dist_to_c3 ~ 2,
          TRUE ~ 3
        )
      ) %>%
      select(x, y, point_id, cluster) %>%
      ungroup()
  } else if (step_type == "update") {
    # อัปเดต centroids
    data %>%
      group_by(cluster) %>%
      summarise(
        x = mean(x),
        y = mean(y),
        .groups = "drop"
      ) %>%
      arrange(cluster)
  }
}

# ฟังก์ชันที่ 3: วาดภาพแต่ละขั้นตอน
plot_kmeans_step <- function(data, centroids = NULL, title, show_assignments = FALSE) {
  # สี colorblind-friendly
  cluster_colors <- c("#E69F00", "#56B4E9", "#009E73")
  
  p <- ggplot(data, aes(x = x, y = y))
  
  if (show_assignments && "cluster" %in% names(data)) {
    p <- p + geom_point(aes(color = factor(cluster)), size = 3, alpha = 0.8)
  } else {
    p <- p + geom_point(size = 3, alpha = 0.8, color = "gray30")
  }
  
  # เพิ่ม centroids ถ้ามี
  if (!is.null(centroids)) {
    p <- p + geom_point(data = centroids, aes(x = x, y = y), 
                        color = cluster_colors[1:nrow(centroids)], 
                        size = 8, shape = 8, stroke = 3)
  }
  
  p <- p + 
    scale_color_manual(values = cluster_colors, guide = "none") +
    labs(title = title, x = "X", y = "Y") +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, hjust = 0.5, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      text = element_text(family = "ChulaCharasNew"),
      aspect.ratio = 1
    ) +
    coord_fixed()
  
  return(p)
}

# ฟังก์ชันที่ 4: สร้างสื่อการเรียนรู้ทั้งหมด
create_kmeans_tutorial <- function() {
  # เริ่มต้นข้อมูล
  data <- generate_sample_data()
  
  # กำหนด centroids เริ่มต้น
  initial_centroids <- tibble(
    x = c(3, 6, 4),
    y = c(4, 4, 2),
    cluster = 1:3
  )
  
  # สร้าง plots แต่ละขั้นตอน
  plots <- list()
  
  # ขั้นตอนที่ 1: ข้อมูลเริ่มต้น
  plots$step1 <- plot_kmeans_step(
    data, 
    title = "ขั้นตอนที่ 1: ข้อมูลเริ่มต้น"
  )
  
  # ขั้นตอนที่ 2: สุ่ม centroids
  plots$step2 <- plot_kmeans_step(
    data, 
    initial_centroids,
    title = "ขั้นตอนที่ 2: สุ่ม Centroids เริ่มต้น"
  )
  
  # เริ่ม iterations
  current_centroids <- initial_centroids
  current_data <- data
  
  for (iter in 1:3) {
    # Assign clusters
    current_data <- kmeans_step(current_data, current_centroids, "assign")
    
    # Plot assignments
    plots[[paste0("iter", iter, "_assign")]] <- plot_kmeans_step(
      current_data, 
      current_centroids,
      title = paste("Iteration", iter, ": การจัดกลุ่ม"),
      show_assignments = TRUE
    )
    
    # Update centroids
    new_centroids <- kmeans_step(current_data, current_centroids, "update")
    
    # Plot new centroids (except for last iteration)
    if (iter < 3) {
      plots[[paste0("iter", iter, "_update")]] <- plot_kmeans_step(
        current_data, 
        new_centroids,
        title = paste("Iteration", iter, ": อัปเดต Centroids"),
        show_assignments = TRUE
      )
      current_centroids <- new_centroids
    } else {
      # Final result
      plots$final <- plot_kmeans_step(
        current_data, 
        new_centroids,
        title = "ผลลัพธ์สุดท้าย: กลุ่มที่ได้",
        show_assignments = TRUE
      )
    }
  }
  
  return(plots)
}

# ใช้งาน: สร้างสื่อการเรียนรู้
plots <- create_kmeans_tutorial()

# จัดเรียงแบบ 2x3
(plots$step1 + plots$step2 + plots$iter1_assign) /
  (plots$iter1_update + plots$iter2_assign + plots$final)

# หรือแสดงทีละขั้นตอน
# plots$step1
# plots$step2
# plots$iter1_assign
# plots$iter1_update
# plots$iter2_assign
# plots$final

# ตัวอย่างการปรับแต่งเพิ่มเติม
create_detailed_tutorial <- function() {
  plots <- create_kmeans_tutorial()
  
  # เพิ่ม annotation
  annotated_plots <- map(plots, ~ {
    .x + theme(
      plot.margin = margin(20, 20, 20, 20),
      plot.background = element_rect(fill = "white", color = "gray90", linewidth = 1),
      text = element_text(family = "ChulaCharasNew")
    )
  })
  
  return(annotated_plots)
}

# การบันทึกภาพสำหรับการใช้งานทางวิชาการ
save_tutorial_plots <- function(plots, width = 12, height = 8) {
  combined_plot <- (plots$step1 + plots$step2 + plots$iter1_assign) /
    (plots$iter1_update + plots$iter2_assign + plots$final)
  
  ggsave("kmeans_tutorial.png", combined_plot, 
         width = width, height = height, dpi = 300, bg = "white")
  
  ggsave("kmeans_tutorial.pdf", combined_plot, 
         width = width, height = height, bg = "white")
}

# ใช้งาน
# plots <- create_kmeans_tutorial()
# save_tutorial_plots(plots)