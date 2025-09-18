# การสร้างภาพประกอบ (Visualization)

library(tidyverse)
library(plotly)
library(networkD3)
library(RColorBrewer)

# โหลดข้อมูล (จะโหลดจากไฟล์ที่เรียกใช้แทน)
# source("../data/generate_dataset.R")  # comment ออกเพื่อให้เรียกจากที่อื่นได้
# source("../sankey.r")                 # comment ออกเพื่อให้เรียกจากที่อื่นได้

# ==================== Main Visualization Functions ====================

# 1. Interactive Sankey Diagram
create_interactive_sankey <- function(complete_data) {
  
  cat("Creating Sankey Diagram...\n")
  
  sankey_data <- create_sankey_data(complete_data)
  
  # สร้าง color palette
  node_colors <- c(
    rep("#1f77b4", sum(sankey_data$nodes$type == "course")),    # สีน้ำเงินสำหรับ courses
    rep("#ff7f0e", sum(sankey_data$nodes$type == "subplo")),    # สีส้มสำหรับ sub-PLOs  
    rep("#2ca02c", sum(sankey_data$nodes$type == "plo"))        # สีเขียวสำหรับ PLOs
  )
  
  # สร้าง Sankey
  p <- sankeyNetwork(
    Links = sankey_data$links,
    Nodes = sankey_data$nodes,
    Source = "source_index", Target = "target_index", Value = "strength",
    NodeID = "node_label", NodeGroup = "type",
    colourScale = JS('d3.scaleOrdinal(["#1f77b4", "#ff7f0e", "#2ca02c"])'),
    fontSize = 12, nodeWidth = 30, nodePadding = 10,
    margin = list(top = 50, right = 50, bottom = 50, left = 50),
    height = 600, width = 1000,
    iterations = 100
  )
  
  return(p)
}

# 2. Course-PLO Heatmap
create_course_plo_heatmap <- function(complete_data) {
  
  cat("Creating Heatmap...\n")
  
  # เตรียมข้อมูลสำหรับ heatmap
  heatmap_data <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, course_name_th, plo_id) %>%
    summarise(
      connection_strength = n_distinct(clo_number, subplo_id),
      keyword_intensity = sum(score, na.rm = TRUE),
      avg_keyword_score = mean(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      combined_strength = connection_strength + (keyword_intensity / 10),
      course_short = str_trunc(course_name_th, 30),
      plo_label = paste("PLO", plo_id)
    )
  
  # สร้าง heatmap
  p <- ggplot(heatmap_data, aes(x = plo_label, y = reorder(course_short, course_id))) +
    geom_tile(aes(fill = combined_strength), color = "white", size = 0.5) +
    geom_text(aes(label = ifelse(combined_strength > 0, 
                                round(combined_strength, 1), "")), 
              size = 3.5, color = "white", fontface = "bold") +
    scale_fill_gradient2(
      low = "#E8E8E8", mid = "#FFA500", high = "#FF4500",
      midpoint = max(heatmap_data$combined_strength, na.rm = TRUE) / 2,
      name = "Strength\nScore",
      na.value = "#F0F0F0"
    ) +
    labs(
      title = "Course-PLO Alignment Strength Heatmap",
      subtitle = "ความแข็งแกรงของการเชื่อมโยงระหว่างรายวิชาและ PLO",
      x = "Program Learning Outcomes (PLO)",
      y = "รายวิชา (Courses)",
      caption = "หมายเหตุ: ตัวเลขแสดงคะแนนความแข็งแกรง (connections + keyword intensity)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11),
      axis.text.x = element_text(size = 10),
      axis.text.y = element_text(size = 9),
      axis.title = element_text(size = 11),
      legend.title = element_text(size = 10),
      panel.grid = element_blank()
    )
  
  return(ggplotly(p, tooltip = c("x", "y", "fill")))
}

# 3. Keywords Analysis Chart
create_keywords_analysis <- function(complete_data) {
  
  cat("Creating Keywords Analysis...\n")
  
  # Top keywords by score และ reach
  top_keywords <- complete_data %>%
    filter(mapped == TRUE & !is.na(keyword)) %>%
    group_by(keyword) %>%
    summarise(
      keyword_score = first(score),
      course_reach = n_distinct(course_id),
      clo_impact = n_distinct(course_id, clo_number),
      total_occurrences = n(),
      .groups = "drop"
    ) %>%
    mutate(
      impact_score = keyword_score * course_reach,
      keyword_short = str_trunc(keyword, 25)
    ) %>%
    arrange(desc(impact_score)) %>%
    head(15)
  
  # สร้างกราฟ
  p <- ggplot(top_keywords, aes(x = reorder(keyword_short, impact_score), 
                               y = impact_score)) +
    geom_col(aes(fill = keyword_score), width = 0.7, alpha = 0.8) +
    geom_text(aes(label = paste0("Score: ", keyword_score, 
                                "\nReach: ", course_reach, " courses")), 
              hjust = -0.05, size = 2.8) +
    scale_fill_gradient2(
      low = "#FFF2CC", mid = "#FFB366", high = "#FF6B35",
      midpoint = mean(top_keywords$keyword_score),
      name = "Keyword\nScore"
    ) +
    coord_flip() +
    labs(
      title = "Top 15 High-Impact Keywords",
      subtitle = "Keywords ที่มีผลกระทบสูงต่อหลักสูตร (Score × Course Reach)",
      x = NULL,
      y = "Impact Score (Score × Reach)",
      caption = "หมายเหตุ: Impact Score = Keyword Score × จำนวนรายวิชาที่เกี่ยวข้อง"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11),
      axis.text.y = element_text(size = 9),
      legend.position = "bottom"
    )
  
  return(ggplotly(p, tooltip = c("y", "fill", "x")))
}

# 4. Balance Analysis Radar Chart
create_balance_radar <- function(complete_data) {
  
  cat("Creating Balance Analysis...\n")
  
  # คำนวณการกระจายตัวของ PLO
  plo_distribution <- complete_data %>%
    filter(mapped == TRUE) %>%
    count(plo_id, plo_name) %>%
    mutate(
      proportion = n / sum(n),
      expected_proportion = 0.25,  # 25% สำหรับแต่ละ PLO
      deviation = abs(proportion - expected_proportion),
      balance_score = 1 - deviation,
      plo_label = paste("PLO", plo_id)
    )
  
  # สร้าง bar chart แสดง balance
  p <- ggplot(plo_distribution, aes(x = plo_label, y = proportion)) +
    geom_col(aes(fill = balance_score), width = 0.6, alpha = 0.8) +
    geom_hline(yintercept = 0.25, linetype = "dashed", color = "red", size = 1) +
    geom_text(aes(label = paste0(round(proportion * 100, 1), "%\n",
                                "Balance: ", round(balance_score, 2))), 
              vjust = -0.5, size = 3.5) +
    scale_fill_gradient2(
      low = "#FF6B6B", mid = "#FFE66D", high = "#4ECDC4",
      midpoint = 0.75, name = "Balance\nScore"
    ) +
    scale_y_continuous(labels = scales::percent_format(), 
                      limits = c(0, max(plo_distribution$proportion) * 1.2)) +
    labs(
      title = "PLO Balance Analysis",
      subtitle = "การกระจายตัวของ Mappings ระหว่าง PLO (เส้นแดง = เป้าหมาย 25%)",
      x = "Program Learning Outcomes",
      y = "สัดส่วนของ Mappings",
      caption = "Balance Score: 1.0 = สมดุลสมบูรณ์, 0.0 = ไม่สมดุลมาก"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11),
      legend.position = "bottom"
    )
  
  return(ggplotly(p, tooltip = c("x", "y", "fill")))
}

# 5. Strategic Dashboard
create_strategic_dashboard <- function(complete_data) {
  
  cat("Creating Strategic Dashboard...\n")
  
  # คำนวณ strategic metrics
  strategic_data <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, course_name_th) %>%
    summarise(
      total_keyword_score = sum(score, na.rm = TRUE),
      high_value_keywords = sum(score >= 7, na.rm = TRUE),
      plo_coverage = n_distinct(plo_id),
      subplo_coverage = n_distinct(subplo_id),
      clo_count = n_distinct(clo_number),
      total_mappings = n(),
      .groups = "drop"
    ) %>%
    left_join(courses %>% select(course_id, hours), by = "course_id") %>%
    mutate(
      strategic_score = (total_keyword_score * 0.4) + 
                       (high_value_keywords * 5) + 
                       (plo_coverage * 10) + 
                       (subplo_coverage * 2) + 
                       (hours * 0.1),
      efficiency_score = strategic_score / hours,
      importance_category = case_when(
        strategic_score >= 100 ~ "Critical",
        strategic_score >= 70 ~ "High Priority", 
        strategic_score >= 40 ~ "Important",
        TRUE ~ "Supporting"
      ),
      course_short = str_trunc(course_name_th, 25)
    ) %>%
    arrange(desc(strategic_score))
  
  # สร้าง bubble chart
  p <- ggplot(strategic_data, aes(x = plo_coverage, y = subplo_coverage, 
                                 size = strategic_score, color = importance_category)) +
    geom_point(alpha = 0.7) +
    geom_text(aes(label = course_short), vjust = -1.2, size = 3) +
    scale_size_continuous(range = c(3, 15), name = "Strategic\nScore") +
    scale_color_manual(
      values = c("Critical" = "#FF4757", "High Priority" = "#FF6B35", 
                "Important" = "#FFA726", "Supporting" = "#66BB6A"),
      name = "Importance\nCategory"
    ) +
    scale_x_continuous(breaks = 1:4, limits = c(0.5, 4.5)) +
    scale_y_continuous(breaks = seq(0, 12, 2)) +
    labs(
      title = "Strategic Importance Dashboard",
      subtitle = "ตำแหน่งเชิงกลยุทธ์ของรายวิชา (PLO Coverage vs Sub-PLO Coverage)",
      x = "จำนวน PLO ที่ครอบคลุม",
      y = "จำนวน Sub-PLO ที่ครอบคลุม", 
      caption = "ขนาดของจุด = Strategic Score, สี = ระดับความสำคัญ"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11),
      legend.position = "right",
      panel.grid.minor = element_blank()
    )
  
  return(ggplotly(p, tooltip = c("x", "y", "size", "colour")))
}

# ==================== Generate Complete Visualization Suite ====================

generate_visualization_suite <- function(complete_data, save_outputs = TRUE) {
  
  cat("=== Generating Complete Visualization Suite ===\n")
  cat("Start time:", format(Sys.time(), "%H:%M:%S"), "\n\n")
  
  # สร้างกราฟทั้งหมด
  viz_suite <- list(
    sankey = create_interactive_sankey(complete_data),
    heatmap = create_course_plo_heatmap(complete_data), 
    keywords = create_keywords_analysis(complete_data),
    balance = create_balance_radar(complete_data),
    strategic = create_strategic_dashboard(complete_data)
  )
  
  cat("\n=== Visualization Suite Complete ===\n")
  cat("Generated visualizations:\n")
  cat("  ✅ Interactive Sankey Diagram\n")
  cat("  ✅ Course-PLO Heatmap\n") 
  cat("  ✅ Keywords Analysis\n")
  cat("  ✅ Balance Analysis\n")
  cat("  ✅ Strategic Dashboard\n")
  
  if(save_outputs) {
    cat("\nSaving to outputs/charts/...\n")
    
    # บันทึกเป็น HTML files สำหรับ interactive plots
    htmlwidgets::saveWidget(viz_suite$sankey, 
                           "/outputs/charts/sankey_diagram.html")
    htmlwidgets::saveWidget(viz_suite$heatmap, 
                           "/outputs/charts/course_plo_heatmap.html")
    htmlwidgets::saveWidget(viz_suite$keywords, 
                           "/outputs/charts/keywords_analysis.html")
    htmlwidgets::saveWidget(viz_suite$balance, 
                           "/outputs/charts/balance_analysis.html") 
    htmlwidgets::saveWidget(viz_suite$strategic, 
                           "/outputs/charts/strategic_dashboard.html")
    
    cat("  💾 Files saved successfully!\n")
  }
  
  cat("End time:", format(Sys.time(), "%H:%M:%S"), "\n")
  
  return(viz_suite)
}

# ==================== Main Execution ====================

if(!exists("complete_dataset")) {
  complete_dataset <- create_complete_dataset()
}

# สร้าง visualization suite
visualizations <- generate_visualization_suite(complete_dataset, save_outputs = TRUE)

# แสดง preview ของแต่ละกราฟ
cat("\n=== VISUALIZATION PREVIEWS ===\n")

# แสดง Sankey
cat("1. Sankey Diagram - แสดงการไหลของการเชื่อมโยง\n")
print(visualizations$sankey)

# แสดง Heatmap
cat("\n2. Heatmap - แสดงความแข็งแกรงของการเชื่อมโยง\n") 
print(visualizations$heatmap)

# แสดง Keywords
cat("\n3. Keywords Analysis - แสดง keywords ที่มีผลกระทบสูง\n")
print(visualizations$keywords)

# แสดง Balance
cat("\n4. Balance Analysis - แสดงความสมดุลของ PLO\n")
print(visualizations$balance)

# แสดง Strategic
cat("\n5. Strategic Dashboard - แสดงตำแหน่งเชิงกลยุทธ์\n")
print(visualizations$strategic)

# บันทึกผลลัพธ์
save(visualizations, file = "/outputs/visualization_suite.RData")

cat("\n🎉 Visualization Suite Generation Complete! 🎉\n")
