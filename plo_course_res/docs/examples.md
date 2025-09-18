# ตัวอย่างการใช้งาน PLO Course Analysis

## การเตรียมข้อมูล

### 1. การติดตั้ง R Packages
```r
# ติดตั้ง packages ที่จำเป็น
install.packages(c(
  "tidyverse",    # การจัดการข้อมูล
  "readxl",       # อ่านไฟล์ Excel
  "plotly",       # กราฟเชิงโต้ตอบ
  "networkD3",    # Sankey diagram
  "heatmaply",    # Heatmap เชิงโต้ตอบ
  "RColorBrewer", # สี
  "htmlwidgets"   # บันทึกกราฟเป็น HTML
))
```

### 2. การโหลดและรันระบบ
```r
# ตั้งค่า working directory
setwd("/path/to/plo_course_res")

# โหลดข้อมูลและฟังก์ชัน
source("data/generate_dataset.R")
source("sankey.r")

# สร้างชุดข้อมูลสมบูรณ์
complete_dataset <- create_complete_dataset()

# ตรวจสอบข้อมูล
summarize_course_data()
check_subplo_coverage()
```

## การวิเคราะห์พื้นฐาน

### 1. การวิเคราะห์การครอบคลุม (Coverage Analysis)
```r
# รันการวิเคราะห์การครอบคลุม
source("analysis/coverage_analysis.R")

# ผลลัพธ์ที่ได้:
# - overall_coverage: สรุปการครอบคลุม PLO และ sub-PLO
# - course_coverage: การครอบคลุมแยกตามรายวิชา
# - plo_coverage: การครอบคลุมแยกตาม PLO
# - gaps: รายการ sub-PLO ที่ยังไม่ครอบคลุม

# ดูผลลัพธ์
print(coverage_analysis$data$overall)
head(coverage_analysis$data$by_course)
```

### 2. การวิเคราะห์ตัวชี้วัดครบถ้วน
```r
# สร้างตัวชี้วัดทั้งหมด
metrics_analysis <- generate_metrics_summary(complete_dataset)

# ดูสรุปหลัก
print(metrics_analysis$coverage$overall_plo)
print(metrics_analysis$balance$overall_balance)
head(metrics_analysis$strategic$course_strategic)
```

## การสร้างภาพประกอบ

### 1. การสร้าง Sankey Diagram
```r
# สร้างข้อมูลสำหรับ Sankey
sankey_data <- create_sankey_data(complete_dataset)

# สร้างกราฟ Sankey (ต้องมี networkD3)
library(networkD3)

sankey_plot <- sankeyNetwork(
  Links = sankey_data$links,
  Nodes = sankey_data$nodes,
  Source = "source_index", 
  Target = "target_index", 
  Value = "strength",
  NodeID = "node_label",
  fontSize = 12,
  nodeWidth = 30
)

# แสดงกราฟ
sankey_plot

# บันทึกกราฟ
htmlwidgets::saveWidget(sankey_plot, "outputs/charts/sankey.html")
```

### 2. การสร้าง Heatmap
```r
# สร้างข้อมูลสำหรับ Heatmap
heatmap_data <- create_heatmap_data(complete_dataset)

# สร้าง Heatmap ด้วย ggplot2
library(ggplot2)

heatmap_plot <- ggplot(heatmap_data, 
                      aes(x = subplo_id, y = course_short, 
                          fill = intensity)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "white", mid = "orange", high = "red") +
  theme_minimal() +
  labs(title = "Course-SubPLO Intensity Heatmap")

print(heatmap_plot)
```

### 3. การรันระบบ Visualization แบบครบถ้วน
```r
# รันการสร้างภาพประกอบทั้งหมด
source("analysis/visualization.R")

# ระบบจะสร้าง:
# - Interactive Sankey Diagram
# - Course-PLO Heatmap  
# - Keywords Analysis
# - Balance Analysis
# - Strategic Dashboard

# ไฟล์จะถูกบันทึกใน outputs/charts/
```

## การตีความผลลัพธ์

### 1. การอ่านผล Coverage Analysis
```r
# ตัวอย่างผลลัพธ์
# PLO Coverage: 100% (4/4 PLOs)
# Sub-PLO Coverage: 91.7% (11/12 sub-PLOs)

# การตีความ:
if(coverage_analysis$data$overall$plo_coverage_pct == 100) {
  cat("✅ ครอบคลุม PLO ได้ครบทั้ง 4 ด้าน\n")
} else {
  cat("⚠️ ยังมี PLO ที่ไม่ได้รับการครอบคลุม\n")
}

if(coverage_analysis$data$overall$subplo_coverage_pct >= 90) {
  cat("✅ ครอบคลุม sub-PLO ได้ดี (≥90%)\n")
} else {
  cat("⚠️ การครอบคลุม sub-PLO ต้องปรับปรุง\n")
}
```

### 2. การหา Gap และข้อเสนะแนะ
```r
# หา sub-PLO ที่ยังไม่ครอบคลุม
gaps <- identify_coverage_gaps(complete_dataset)

if(nrow(gaps) > 0) {
  cat("Sub-PLO ที่ต้องเพิ่ม:\n")
  for(i in 1:nrow(gaps)) {
    cat("-", gaps$subplo_id[i], ":", gaps$subplo_name_th[i], "\n")
  }
} else {
  cat("ไม่มี Gap - ครอบคลุมครบแล้ว\n")
}
```

### 3. การวิเคราะห์ Strategic Importance
```r
# ดูรายวิชาที่มีความสำคัญสูง
top_courses <- metrics_analysis$strategic$course_strategic %>%
  filter(importance_category %in% c("Critical", "High Priority")) %>%
  select(course_short, strategic_score, importance_category)

cat("รายวิชาสำคัญ:\n")
print(top_courses)

# ดู keywords ที่มีผลกระทบสูง
top_keywords <- metrics_analysis$strategic$high_impact_keywords %>%
  head(10) %>%
  select(keyword, keyword_score, course_reach, impact_category)

cat("\nKeywords สำคัญ:\n")
print(top_keywords)
```

## การสร้างรายงาน

### 1. รายงานสำหรับผู้บริหาร
```r
# สร้างรายงานสรุปสำหรับผู้บริหาร
executive_summary <- function(metrics) {
  
  cat("=== Executive Summary ===\n")
  cat("วันที่:", format(Sys.Date(), "%d/%m/%Y"), "\n\n")
  
  cat("📊 ภาพรวมหลักสูตร\n")
  cat("- PLO Coverage:", metrics$coverage$overall_plo$plo_coverage_pct, "%\n")
  cat("- Sub-PLO Coverage:", metrics$coverage$overall_subplo$subplo_coverage_pct, "%\n")
  cat("- Balance Level:", metrics$balance$overall_balance$balance_level, "\n")
  
  cat("\n🎯 รายวิชาสำคัญ (Top 3)\n")
  top3 <- head(metrics$strategic$course_strategic, 3)
  for(i in 1:3) {
    cat(sprintf("  %d. %s (Score: %.1f)\n", 
                i, top3$course_short[i], top3$strategic_score[i]))
  }
  
  cat("\n💡 ข้อเสนะแนะหลัก\n")
  if(metrics$coverage$overall_subplo$subplo_coverage_pct < 100) {
    cat("- ควรเพิ่มการครอบคลุม sub-PLO ที่ขาดหาย\n")
  }
  
  if(metrics$balance$overall_balance$avg_balance < 0.8) {
    cat("- ควรปรับสมดุลการกระจาย PLO\n")
  }
}

executive_summary(metrics_analysis)
```

### 2. รายงานสำหรับอาจารย์
```r
# รายงานเฉพาะรายวิชา
course_specific_report <- function(course_id, complete_data, metrics) {
  
  course_info <- complete_data %>%
    filter(course_id == !!course_id) %>%
    slice(1)
  
  cat("=== รายงานรายวิชา ===\n")
  cat("รายวิชา:", course_info$course_name_th, "\n")
  cat("รหัสวิชา:", course_info$course_code, "\n\n")
  
  # Coverage ของรายวิชานี้
  course_coverage <- metrics$coverage$by_course %>%
    filter(course_id == !!course_id)
  
  cat("📊 การครอบคลุม PLO\n")
  cat("- Sub-PLO Coverage:", course_coverage$subplo_coverage_pct, "%\n")
  cat("- PLO Coverage:", course_coverage$plo_coverage_pct, "%\n")
  
  # Strategic Score
  strategic_info <- metrics$strategic$course_strategic %>%
    filter(course_id == !!course_id)
  
  cat("\n🎯 ความสำคัญเชิงกลยุทธ์\n")
  cat("- Strategic Score:", strategic_info$strategic_score, "\n")
  cat("- Category:", strategic_info$importance_category, "\n")
  
  # CLO-PLO mappings
  mappings <- complete_data %>%
    filter(course_id == !!course_id & mapped == TRUE) %>%
    select(clo_number, clo_description, subplo_id, plo_id) %>%
    arrange(clo_number)
  
  cat("\n🔗 CLO-PLO Mappings\n")
  print(mappings)
}

# ใช้งาน
course_specific_report(1, complete_dataset, metrics_analysis)
```

## การใช้งานขั้นสูง

### 1. การเปรียบเทียบระหว่างภาคเรียน
```r
# ถ้ามีข้อมูลหลายภาคเรียน
compare_semesters <- function(data_sem1, data_sem2) {
  
  metrics1 <- generate_metrics_summary(data_sem1)
  metrics2 <- generate_metrics_summary(data_sem2)
  
  comparison <- tibble(
    metric = c("PLO Coverage", "Sub-PLO Coverage", "Balance Score"),
    semester_1 = c(
      metrics1$coverage$overall_plo$plo_coverage_pct,
      metrics1$coverage$overall_subplo$subplo_coverage_pct,
      metrics1$balance$overall_balance$avg_balance
    ),
    semester_2 = c(
      metrics2$coverage$overall_plo$plo_coverage_pct,
      metrics2$coverage$overall_subplo$subplo_coverage_pct, 
      metrics2$balance$overall_balance$avg_balance
    )
  ) %>%
    mutate(
      improvement = semester_2 - semester_1,
      trend = case_when(
        improvement > 0 ~ "↗️ Improved",
        improvement < 0 ~ "↘️ Declined", 
        TRUE ~ "→ Stable"
      )
    )
  
  return(comparison)
}
```

### 2. การสร้าง Custom Metrics
```r
# สร้าง metric ใหม่
calculate_custom_metric <- function(complete_data) {
  
  # ตัวอย่าง: Diversity Index
  diversity_index <- complete_data %>%
    filter(mapped == TRUE) %>%
    count(plo_id) %>%
    mutate(proportion = n / sum(n)) %>%
    summarise(
      diversity = -sum(proportion * log(proportion)),  # Shannon Index
      max_diversity = log(n_distinct(plo_id)),
      normalized_diversity = diversity / max_diversity
    )
  
  return(diversity_index)
}

custom_metrics <- calculate_custom_metric(complete_dataset)
print(custom_metrics)
```

## Troubleshooting

### ปัญหาที่พบบ่อย

1. **ไม่สามารถโหลดข้อมูลได้**
```r
# ตรวจสอบ working directory
getwd()

# ตรวจสอบว่ามีไฟล์หรือไม่
file.exists("data/generate_dataset.R")

# ตรวจสอบ packages
library(tidyverse)  # ถ้า error แสดงว่าต้อง install
```

2. **กราฟไม่แสดง**
```r
# สำหรับ plotly
library(plotly)

# สำหรับ networkD3  
library(networkD3)

# ตรวจสอบ browser
options(viewer = NULL)  # บังคับใช้ external browser
```

3. **ข้อมูลไม่ครบ**
```r
# ตรวจสอบข้อมูล missing
validation_result <- validate_complete_data(complete_dataset)
print(validation_result)

# ตรวจสอบ mapping
table(complete_dataset$mapped, useNA = "always")
```

การใช้งานระบบนี้จะช่วยให้คุณสามารถวิเคราะห์และปรับปรุงหลักสูตรได้อย่างเป็นระบบและมีประสิทธิภาพ
