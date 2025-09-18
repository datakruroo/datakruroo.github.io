# การวิเคราะห์การครอบคลุม (Coverage Analysis)

library(tidyverse)
library(plotly)

# โหลดข้อมูลจาก generate_dataset.R
source("../data/generate_dataset.R")

# ==================== Coverage Analysis Functions ====================

# 1. PLO Coverage Analysis
analyze_plo_coverage <- function(complete_data) {
  
  plo_coverage <- complete_data %>%
    filter(mapped == TRUE) %>%
    summarise(
      total_plo = n_distinct(subplo_info$plo_id),
      covered_plo = n_distinct(plo_id, na.rm = TRUE),
      plo_coverage_pct = round(covered_plo / total_plo * 100, 1),
      total_subplo = n_distinct(subplo_info$subplo_id),
      covered_subplo = n_distinct(subplo_id, na.rm = TRUE),
      subplo_coverage_pct = round(covered_subplo / total_subplo * 100, 1)
    )
  
  return(plo_coverage)
}

# 2. Coverage by Course
analyze_course_coverage <- function(complete_data) {
  
  course_coverage <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, course_name_th) %>%
    summarise(
      covered_subplo = n_distinct(subplo_id),
      covered_plo = n_distinct(plo_id),
      total_clo = n_distinct(clo_number),
      total_mappings = n(),
      avg_keyword_score = mean(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(courses %>% select(course_id, hours, course_code), by = "course_id") %>%
    mutate(
      subplo_coverage_pct = round(covered_subplo / 12 * 100, 1),
      plo_coverage_pct = round(covered_plo / 4 * 100, 1),
      mappings_per_hour = round(total_mappings / hours, 2),
      course_short = str_trunc(course_name_th, 35)
    ) %>%
    arrange(desc(covered_subplo))
  
  return(course_coverage)
}

# 3. Coverage by PLO
analyze_plo_detail_coverage <- function(complete_data) {
  
  plo_detail <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(plo_id, plo_name) %>%
    summarise(
      course_count = n_distinct(course_id),
      clo_count = n_distinct(course_id, clo_number),
      subplo_mapped = n_distinct(subplo_id),
      total_mappings = n(),
      avg_keyword_score = mean(score, na.rm = TRUE),
      total_keyword_score = sum(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(
      subplo_info %>% count(plo_id, name = "total_subplo"),
      by = "plo_id"
    ) %>%
    mutate(
      subplo_coverage_pct = round(subplo_mapped / total_subplo * 100, 1),
      plo_name_short = str_trunc(plo_name, 40),
      avg_mappings_per_course = round(total_mappings / course_count, 1)
    ) %>%
    arrange(desc(total_mappings))
  
  return(plo_detail)
}

# 4. Gap Analysis - หา sub-PLO ที่ยังไม่ครอบคลุม
identify_coverage_gaps <- function(complete_data) {
  
  covered_subplo <- complete_data %>%
    filter(mapped == TRUE) %>%
    distinct(subplo_id) %>%
    pull(subplo_id)
  
  gaps <- subplo_info %>%
    filter(!subplo_id %in% covered_subplo) %>%
    select(subplo_id, subplo_name_th, plo_id, plo_name) %>%
    mutate(
      gap_type = case_when(
        plo_id == 1 ~ "Design & Implementation Gap",
        plo_id == 2 ~ "Decision & Management Gap",  
        plo_id == 3 ~ "Self-Development Gap",
        plo_id == 4 ~ "Global Citizenship Gap"
      )
    )
  
  return(gaps)
}

# ==================== Visualization Functions ====================

# 1. Coverage Overview Chart
plot_coverage_overview <- function(coverage_data, course_coverage) {
  
  # เตรียมข้อมูลสำหรับกราฟ
  overview_data <- tibble(
    metric = c("PLO Coverage", "Sub-PLO Coverage", "Average Course Coverage"),
    percentage = c(
      coverage_data$plo_coverage_pct,
      coverage_data$subplo_coverage_pct,
      mean(course_coverage$subplo_coverage_pct)
    ),
    color = c("#2E86AB", "#A23B72", "#F18F01")
  )
  
  p <- ggplot(overview_data, aes(x = metric, y = percentage, fill = color)) +
    geom_col(width = 0.6, alpha = 0.8) +
    geom_text(aes(label = paste0(percentage, "%")), 
              vjust = -0.5, size = 4, fontface = "bold") +
    scale_fill_identity() +
    scale_y_continuous(limits = c(0, 110), breaks = seq(0, 100, 20)) +
    labs(
      title = "ภาพรวมการครอบคลุม PLO และ Sub-PLO",
      subtitle = "การประเมินความสมบูรณ์ของหลักสูตร",
      x = NULL,
      y = "ร้อยละการครอบคลุม",
      caption = "เกณฑ์มาตรฐาน: ≥80% = ดี, ≥90% = ดีเยี่ยม"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11),
      axis.text.x = element_text(size = 10),
      legend.position = "none"
    )
  
  return(ggplotly(p, tooltip = c("x", "y")))
}

# 2. Course Coverage Comparison
plot_course_coverage <- function(course_coverage) {
  
  p <- ggplot(course_coverage, aes(x = reorder(course_short, subplo_coverage_pct), 
                                   y = subplo_coverage_pct)) +
    geom_col(aes(fill = subplo_coverage_pct), width = 0.7, alpha = 0.8) +
    geom_text(aes(label = paste0(subplo_coverage_pct, "%")), 
              hjust = -0.1, size = 3.5) +
    scale_fill_gradient2(
      low = "#E63946", mid = "#F77F00", high = "#06D6A0",
      midpoint = 50, name = "Coverage %"
    ) +
    scale_y_continuous(limits = c(0, max(course_coverage$subplo_coverage_pct) + 10)) +
    coord_flip() +
    labs(
      title = "การครอบคลุม Sub-PLO แยกตามรายวิชา",
      subtitle = "เปรียบเทียบระดับการครอบคลุมของแต่ละรายวิชา",
      x = NULL,
      y = "ร้อยละการครอบคลุม Sub-PLO",
      caption = "หมายเหตุ: รายวิชาที่ครอบคลุมสูงจะมีบทบาทหลักในหลักสูตร"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 13, face = "bold"),
      axis.text.y = element_text(size = 9),
      legend.position = "bottom"
    )
  
  return(ggplotly(p, tooltip = c("y", "fill")))
}

# 3. PLO Coverage Distribution
plot_plo_distribution <- function(plo_detail) {
  
  p <- ggplot(plo_detail, aes(x = factor(plo_id), y = total_mappings)) +
    geom_col(aes(fill = factor(plo_id)), width = 0.6, alpha = 0.8) +
    geom_text(aes(label = paste0(total_mappings, " mappings\n", 
                                course_count, " courses")), 
              vjust = -0.5, size = 3.5) +
    scale_fill_brewer(palette = "Set3", name = "PLO") +
    scale_x_discrete(labels = paste("PLO", 1:4)) +
    labs(
      title = "การกระจายตัวของ Mappings แยกตาม PLO",
      subtitle = "จำนวนการเชื่อมโยงและจำนวนรายวิชาที่เกี่ยวข้อง",
      x = "Program Learning Outcomes (PLO)",
      y = "จำนวน CLO-PLO Mappings",
      caption = "หมายเหตุ: ความสูงแสดงจำนวน mappings, ข้อความแสดงจำนวนรายวิชา"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 13, face = "bold"),
      legend.position = "none"
    )
  
  return(ggplotly(p, tooltip = c("x", "y", "fill")))
}

# ==================== Generate Reports ====================

# ฟังก์ชันสร้างรายงานการครอบคลุม
generate_coverage_report <- function(complete_data, save_plots = TRUE) {
  
  cat("=== Coverage Analysis Report ===\n")
  cat("Generated on:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")
  
  # การวิเคราะห์การครอบคลุม
  overall_coverage <- analyze_plo_coverage(complete_data)
  course_coverage <- analyze_course_coverage(complete_data)
  plo_coverage <- analyze_plo_detail_coverage(complete_data)
  gaps <- identify_coverage_gaps(complete_data)
  
  # แสดงผลสรุป
  cat("1. OVERALL COVERAGE\n")
  cat("   - PLO Coverage:", overall_coverage$plo_coverage_pct, "% (", 
      overall_coverage$covered_plo, "/", overall_coverage$total_plo, ")\n")
  cat("   - Sub-PLO Coverage:", overall_coverage$subplo_coverage_pct, "% (", 
      overall_coverage$covered_subplo, "/", overall_coverage$total_subplo, ")\n\n")
  
  cat("2. COURSE COVERAGE RANKING\n")
  for(i in 1:nrow(course_coverage)) {
    cat(sprintf("   %d. %s: %s%% (%d sub-PLOs)\n", 
                i, course_coverage$course_short[i], 
                course_coverage$subplo_coverage_pct[i],
                course_coverage$covered_subplo[i]))
  }
  cat("\n")
  
  cat("3. PLO COVERAGE DISTRIBUTION\n")
  for(i in 1:nrow(plo_coverage)) {
    cat(sprintf("   PLO %d: %d mappings across %d courses (%s%%)\n",
                plo_coverage$plo_id[i], plo_coverage$total_mappings[i],
                plo_coverage$course_count[i], plo_coverage$subplo_coverage_pct[i]))
  }
  cat("\n")
  
  if(nrow(gaps) > 0) {
    cat("4. COVERAGE GAPS\n")
    for(i in 1:nrow(gaps)) {
      cat(sprintf("   - %s: %s\n", gaps$subplo_id[i], 
                  str_trunc(gaps$subplo_name_th[i], 60)))
    }
  } else {
    cat("4. COVERAGE GAPS: None - ครอบคลุมครบทุก sub-PLO\n")
  }
  
  # สร้างกราฟ
  if(save_plots) {
    p1 <- plot_coverage_overview(overall_coverage, course_coverage)
    p2 <- plot_course_coverage(course_coverage)  
    p3 <- plot_plo_distribution(plo_coverage)
    
    return(list(
      data = list(
        overall = overall_coverage,
        by_course = course_coverage,
        by_plo = plo_coverage,
        gaps = gaps
      ),
      plots = list(
        overview = p1,
        course_comparison = p2,
        plo_distribution = p3
      )
    ))
  }
  
  return(list(
    overall = overall_coverage,
    by_course = course_coverage,
    by_plo = plo_coverage,
    gaps = gaps
  ))
}

# ==================== Main Analysis ====================

if(!exists("complete_dataset")) {
  complete_dataset <- create_complete_dataset()
}

# สร้างรายงานการครอบคลุม
coverage_analysis <- generate_coverage_report(complete_dataset, save_plots = TRUE)

# แสดงสรุปสำคัญ
cat("\n=== KEY INSIGHTS ===\n")
cat("✅ Strengths:\n")
if(coverage_analysis$data$overall$plo_coverage_pct == 100) {
  cat("   - ครอบคลุม PLO ได้ครบทั้ง 4 ด้าน\n")
}
if(coverage_analysis$data$overall$subplo_coverage_pct >= 90) {
  cat("   - ครอบคลุม sub-PLO เกือบครบ (≥90%)\n")
}

cat("\n⚠️  Areas for Improvement:\n")
if(coverage_analysis$data$overall$subplo_coverage_pct < 100) {
  cat("   - ยังมี sub-PLO ที่ไม่ได้ครอบคลุม\n")
}

low_coverage_courses <- coverage_analysis$data$by_course %>%
  filter(subplo_coverage_pct < 50)
if(nrow(low_coverage_courses) > 0) {
  cat("   - มีรายวิชาที่ครอบคลุมต่ำ (<50%)\n")
}

cat("\n📊 Top Performing Course:", 
    coverage_analysis$data$by_course$course_short[1], "\n")
cat("🎯 Priority PLO: PLO", 
    coverage_analysis$data$by_plo$plo_id[1], 
    "(", coverage_analysis$data$by_plo$total_mappings[1], "mappings )\n")

# บันทึกผลลัพธ์
save(coverage_analysis, file = "../outputs/coverage_analysis_results.RData")
