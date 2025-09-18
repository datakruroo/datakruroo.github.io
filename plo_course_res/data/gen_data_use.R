library(tidyverse)


# ==================== 1. ข้อมูลรายวิชา ====================
courses <- tibble(
  course_id = 1:5,
  course_code = paste0("COURSE_", sprintf("%02d", 1:5)),
  course_name_th = c(
    "การทำความเข้าใจธรรมชาติและความหลากหลายของผู้เรียน",
    "การประเมินความหลากหลายของผู้เรียน", 
    "การวิเคราะห์การเรียนรู้เพื่อทำความเข้าใจความหลากหลายของผู้เรียน",
    "การส่งเสริมพัฒนาผู้เรียนที่หลากหลาย",
    "การออกแบบกระบวนการส่งเสริมพัฒนาผู้เรียนที่หลากหลาย"
  ),
  course_name_en = c(
    "Understanding learner diversity",
    "Assessment of Learner Diversity",
    "Learning Analytics for Understanding Learner Diversity", 
    "Supports for Learner Diversity",
    "Process Design for Learner Diversity Supports"
  ),
  hours = c(32, 48, 48, 32, 48)
)

# ─────────────────────────────────────────────────────────
# 1) แก้ไขชื่อ Sub-PLO (สะกดไทยให้ถูกต้องเล็กน้อย) – ไม่บังคับถ้าใช้ได้อยู่แล้ว
subplo_info <- tibble(
  subplo_id = c("1.1","1.2","2.1","2.2","2.3","2.4","3.1","3.2","3.3","4.1","4.2","4.3"),
  plo_id    = c(1,1,2,2,2,2,3,3,3,4,4,4),
  subplo_name_th = c(
    "การออกแบบหลักสูตรและการจัดการเรียนรู้ที่ยืดหยุ่นและเน้นผู้เรียนเป็นฐาน",
    "การบูรณาการเทคโนโลยีและปัญญาประดิษฐ์",
    "การตัดสินใจภายใต้การเปลี่ยนแปลง",
    "ภาวะผู้นำเชิงจริยธรรม",
    "การบริหารจัดการเพื่อส่งเสริมการเรียนรู้ตลอดชีวิต",
    "การสื่อสารและการสร้างความร่วมมือ",
    "การเป็นผู้มีกรอบคิดแบบเติบโต",
    "การเป็นผู้มีสมรรถนะการทำงานร่วมกับผู้อื่นในสังคมพหุวัฒนธรรม",
    "การเป็นผู้มีสมรรถนะทางอารมณ์และสังคม",
    "การเป็นพลเมืองโลก",
    "การเป็นผู้ใช้ข้อมูลอย่างมีธรรมาภิบาล",
    "การเป็นผู้มีส่วนร่วมในชุมชนวิชาชีพครู"
  ),
  plo_name = c(
    rep("ออกแบบและปฏิบัติการจัดประสบการณ์การเรียนรู้", 2),
    rep("ตัดสินใจและบริหารการจัดประสบการณ์การเรียนรู้", 4),
    rep("กำกับการเรียนรู้และพัฒนาตนเองด้านวิชาชีพครู", 3),
    rep("แสดงออกถึงความเข้าใจบทบาทของครูในฐานะพลเมืองโลก", 3)
  )
)

# ─────────────────────────────────────────────────────────
# 2) อัปเดต mapping เฉพาะรายวิชา Course 3 ให้ตรงกับตารางใหม่
#    - ลบ mapping เดิมของ course_id == 3
#    - ใส่ mapping ใหม่ตามที่กำหนด

clo_subplo_mapping <-
  clo_subplo_mapping %>% 
  # ลบของเดิมของคอร์ส 3
  filter(course_id != 3) %>% 
  # ใส่ของใหม่ตามตาราง (CLO1–4)
  bind_rows(
    tribble(
      ~course_id, ~clo_number, ~subplo_id, ~mapped,
      3, 1, "1.2", TRUE,
      3, 2, "1.2", TRUE,
      3, 2, "4.1", TRUE,
      3, 3, "1.2", TRUE,
      3, 3, "2.4", TRUE,
      3, 3, "3.2", TRUE,
      3, 3, "4.2", TRUE,
      3, 4, "1.2", TRUE,
      3, 4, "3.2", TRUE,
      3, 4, "4.2", TRUE
    )
  )

# ─────────────────────────────────────────────────────────
# 3) ฟังก์ชันสรุป และฟังก์ชันสร้าง “เมทริกซ์ CLO × Sub-PLO” สำหรับ Course ที่ระบุ

summarize_course_data <- function(courses, subplo_info, keywords_data, clo_subplo_mapping) {
  cat("=== สรุปข้อมูลรายวิชา ===\n")
  cat("จำนวนรายวิชา:", nrow(courses), "\n")
  cat("จำนวน Sub-PLO:", nrow(subplo_info), "\n")
  cat("จำนวน Keywords:", nrow(keywords_data), "\n")
  cat("จำนวน CLO mappings:", nrow(clo_subplo_mapping), "\n")
  if ("hours" %in% names(courses)) {
    cat("รวมชั่วโมงเรียน:", sum(courses$hours), "ชั่วโมง\n")
  }
}


# ฟังก์ชันสร้าง Complete Dataset
create_complete_dataset <- function() {
  
  cat("กำลังรวมข้อมูลทุกระดับ...\n")
  
  # 1. รวมข้อมูลรายวิชา + CLO + sub-PLO
  course_clo_subplo <- clo_mapping %>%
    left_join(clo_subplo_mapping, by = c("course_id", "clo_number")) %>%
    filter(mapped == TRUE | is.na(mapped)) %>%  # เก็บเฉพาะที่ map หรือยังไม่ได้ map
    left_join(courses, by = "course_id") %>%
    left_join(subplo_info, by = "subplo_id") %>%
    select(
      course_id, course_code, course_name_th, course_name_en, hours,
      clo_number, clo_description, 
      subplo_id, subplo_name_th, plo_id, plo_name,
      mapped
    )
  
  # 2. เพิ่มข้อมูล keywords ผ่าน sub-PLO
  complete_data <- course_clo_subplo %>%
    left_join(keywords_data, by = "subplo_id") %>%
    filter(!is.na(subplo_id)) %>%  # เก็บเฉพาะที่มี sub-PLO mapping
    arrange(course_id, clo_number, subplo_id)
  
  return(complete_data)
}

# ฟังก์ชันสร้างข้อมูลสำหรับ Sankey Diagram (แก้ไขแล้วเพื่อแก้ปัญหาการไหล)
create_sankey_data <- function(complete_data) {
  
  # สร้าง nodes และ links สำหรับ Sankey
  nodes_courses <- complete_data %>%
    distinct(course_id, course_name_th) %>%
    mutate(
      node_id = paste0("course_", course_id),
      node_label = str_trunc(course_name_th, 40),
      level = 1,
      type = "course"
    )
  
  nodes_subplo <- complete_data %>%
    distinct(subplo_id, subplo_name_th, plo_id) %>%
    mutate(
      node_id = paste0("subplo_", subplo_id),
      node_label = paste0(subplo_id, ": ", str_trunc(subplo_name_th, 30)),
      level = 2,
      type = "subplo"
    )
  
  nodes_plo <- complete_data %>%
    distinct(plo_id, plo_name) %>%
    mutate(
      node_id = paste0("plo_", plo_id),
      node_label = paste0("PLO ", plo_id, ": ", str_trunc(plo_name, 25)),
      level = 3,
      type = "plo"
    )
  
  # รวม nodes
  all_nodes <- bind_rows(
    select(nodes_courses, node_id, node_label, level, type),
    select(nodes_subplo, node_id, node_label, level, type),  
    select(nodes_plo, node_id, node_label, level, type)
  ) %>%
    mutate(node_index = row_number() - 1)  # สำหรับ JavaScript (0-based index)
  
  # สร้าง links: Course → sub-PLO
  links_course_subplo <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, subplo_id) %>%
    summarise(
      strength = n(),  # จำนวน CLO ที่เชื่อมต่อ
      .groups = "drop"
    ) %>%
    mutate(
      source_id = paste0("course_", course_id),
      target_id = paste0("subplo_", subplo_id),
      link_type = "course_subplo"
    )
  
  # สร้าง links: sub-PLO → PLO (แก้ไขให้สมดุลกัน)
  links_subplo_plo <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(subplo_id, plo_id) %>%
    summarise(
      strength = n(),  # ใช้การนับแบบเดียวกันเพื่อความสมดุล
      .groups = "drop"
    ) %>%
    mutate(
      source_id = paste0("subplo_", subplo_id),
      target_id = paste0("plo_", plo_id),
      link_type = "subplo_plo"
    )
  
  # รวม links
  all_links <- bind_rows(
    select(links_course_subplo, source_id, target_id, strength, link_type),
    select(links_subplo_plo, source_id, target_id, strength, link_type)
  ) %>%
    left_join(all_nodes, by = c("source_id" = "node_id")) %>%
    rename(source_index = node_index) %>%
    select(-node_label, -level, -type) %>%
    left_join(all_nodes, by = c("target_id" = "node_id")) %>%
    rename(target_index = node_index) %>%
    select(source_index, target_index, strength, link_type)
  
  return(list(nodes = all_nodes, links = all_links))
}

# ฟังก์ชันสร้างข้อมูลสำหรับ Heatmap
create_heatmap_data <- function(complete_data) {
  
  # Course x sub-PLO matrix
  course_subplo_matrix <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, course_name_th, subplo_id) %>%
    summarise(
      clo_count = n_distinct(clo_number),
      keyword_count = n_distinct(keyword, na.rm = TRUE),
      avg_keyword_score = mean(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      intensity = clo_count + (avg_keyword_score / 10),  # รวมความเข้มข้น
      course_short = str_trunc(course_name_th, 25)
    )
  
  return(course_subplo_matrix)
}

# ฟังก์ชันสร้างข้อมูล Keywords summary
create_keyword_summary <- function(complete_data) {
  
  keyword_summary <- complete_data %>%
    filter(mapped == TRUE & !is.na(keyword)) %>%
    group_by(keyword, subplo_id) %>%
    summarise(
      score = first(score),
      course_count = n_distinct(course_id),
      clo_count = n_distinct(course_id, clo_number),
      .groups = "drop"
    ) %>%
    left_join(subplo_info, by = "subplo_id") %>%
    arrange(desc(score)) %>%
    mutate(
      importance_rank = row_number(),
      score_category = case_when(
        score >= 8 ~ "Very High",
        score >= 5 ~ "High", 
        score >= 3 ~ "Medium",
        TRUE ~ "Low"
      )
    )
  
  return(keyword_summary)
}

# ==================== 8. ฟังก์ชันคำนวณตัวชี้วัดทางสถิติ ====================

# 1. Coverage Analysis - การวิเคราะห์การครอบคลุม
calculate_coverage_metrics <- function(complete_data) {
  
  cat("=== Coverage Analysis ===\n")
  
  # PLO Coverage
  plo_coverage <- complete_data %>%
    filter(mapped == TRUE) %>%
    summarise(
      total_plo = n_distinct(subplo_info$plo_id),
      covered_plo = n_distinct(plo_id, na.rm = TRUE),
      plo_coverage_pct = round(covered_plo / total_plo * 100, 1)
    )
  
  # Sub-PLO Coverage  
  subplo_coverage <- complete_data %>%
    filter(mapped == TRUE) %>%
    summarise(
      total_subplo = n_distinct(subplo_info$subplo_id),
      covered_subplo = n_distinct(subplo_id, na.rm = TRUE),
      subplo_coverage_pct = round(covered_subplo / total_subplo * 100, 1)
    )
  
  # Coverage by Course
  course_coverage <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, course_name_th) %>%
    summarise(
      covered_subplo = n_distinct(subplo_id),
      covered_plo = n_distinct(plo_id),
      total_clo = n_distinct(clo_number),
      avg_keyword_score = mean(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      subplo_coverage_pct = round(covered_subplo / 12 * 100, 1),
      plo_coverage_pct = round(covered_plo / 4 * 100, 1),
      course_short = str_trunc(course_name_th, 30)
    ) %>%
    arrange(desc(covered_subplo))
  
  # Coverage by PLO
  plo_detail_coverage <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(plo_id, plo_name) %>%
    summarise(
      course_count = n_distinct(course_id),
      clo_count = n_distinct(course_id, clo_number),
      subplo_mapped = n_distinct(subplo_id),
      avg_keyword_score = mean(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(
      subplo_info %>% count(plo_id, name = "total_subplo"),
      by = "plo_id"
    ) %>%
    mutate(
      subplo_coverage_pct = round(subplo_mapped / total_subplo * 100, 1),
      plo_name_short = str_trunc(plo_name, 40)
    ) %>%
    arrange(desc(course_count))
  
  return(list(
    overall_plo = plo_coverage,
    overall_subplo = subplo_coverage,
    by_course = course_coverage,
    by_plo = plo_detail_coverage
  ))
}

# 2. Alignment Strength - ความแข็งแกรงของการเชื่อมโยง
calculate_alignment_strength <- function(complete_data) {
  
  cat("=== Alignment Strength Analysis ===\n")
  
  # Course-PLO Alignment Strength
  course_plo_strength <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, course_name_th, plo_id, plo_name) %>%
    summarise(
      connection_count = n_distinct(clo_number, subplo_id),
      keyword_intensity = sum(score, na.rm = TRUE),
      unique_subplo = n_distinct(subplo_id),
      .groups = "drop"
    ) %>%
    mutate(
      alignment_score = connection_count + (keyword_intensity / 10) + unique_subplo,
      alignment_category = case_when(
        alignment_score >= 15 ~ "Very Strong",
        alignment_score >= 10 ~ "Strong",
        alignment_score >= 5 ~ "Moderate", 
        TRUE ~ "Weak"
      ),
      course_short = str_trunc(course_name_th, 25)
    ) %>%
    arrange(desc(alignment_score))
  
  # Sub-PLO Connection Strength
  subplo_strength <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(subplo_id, subplo_name_th) %>%
    summarise(
      course_connections = n_distinct(course_id),
      clo_connections = n_distinct(course_id, clo_number),
      keyword_intensity = sum(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      connection_strength = course_connections * 3 + clo_connections + (keyword_intensity / 5),
      strength_rank = row_number(desc(connection_strength)),
      subplo_short = str_trunc(subplo_name_th, 35)
    ) %>%
    arrange(desc(connection_strength))
  
  return(list(
    course_plo = course_plo_strength,
    subplo = subplo_strength
  ))
}

# 3. Concentration Index - ความเข้มข้น
calculate_concentration_index <- function(complete_data) {
  
  cat("=== Concentration Index Analysis ===\n")
  
  # PLO Concentration (Herfindahl-Hirschman Index style)
  plo_concentration <- complete_data %>%
    filter(mapped == TRUE) %>%
    count(plo_id, plo_name) %>%
    mutate(
      proportion = n / sum(n),
      concentration_contrib = proportion^2
    ) %>%
    summarise(
      concentration_index = sum(concentration_contrib),
      concentration_level = case_when(
        concentration_index >= 0.5 ~ "Highly Concentrated",
        concentration_index >= 0.25 ~ "Moderately Concentrated",
        TRUE ~ "Well Distributed"
      )
    )
  
  # Course Load Distribution
  course_load <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, course_name_th) %>%
    summarise(
      mapping_load = n(),
      unique_subplo = n_distinct(subplo_id),
      keyword_load = sum(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      load_score = mapping_load + (keyword_load / 10),
      load_rank = row_number(desc(load_score)),
      course_short = str_trunc(course_name_th, 30)
    ) %>%
    arrange(desc(load_score))
  
  # Keyword Concentration by Sub-PLO
  keyword_concentration <- complete_data %>%
    filter(mapped == TRUE & !is.na(keyword)) %>%
    group_by(subplo_id) %>%
    summarise(
      keyword_count = n_distinct(keyword),
      total_score = sum(score),
      avg_score = mean(score),
      score_variance = var(score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      concentration_score = total_score + keyword_count,
      concentration_rank = row_number(desc(concentration_score))
    ) %>%
    arrange(desc(concentration_score))
  
  return(list(
    plo_concentration = plo_concentration,
    course_load = course_load,
    keyword_concentration = keyword_concentration
  ))
}
# ---------- helper: safe entropy ----------
entropy_normalized <- function(weights) {
  w <- weights[weights > 0]
  K <- length(weights)                    # ใช้จำนวนหมวดทั้งหมด (รวมที่น้ำหนักเป็น 0)
  if (sum(weights) == 0 || K <= 1) return(NA_real_)
  p <- weights / sum(weights)
  # ใส่ epsilon กัน log(0) ถ้าจำเป็น (แต่เราคัด w>0 แล้ว)
  H  <- -sum(p * log(p))
  Hmax <- log(K)
  H / Hmax                                # normalized entropy [0,1]
}

# 4. Balance Analysis - การวิเคราะห์ความสมดุล
calculate_balance_metrics <- function(complete_data) {
  
  cat("=== Balance Analysis ===\n")
  
  # PLO Balance
  plo_balance <- complete_data %>%
    filter(mapped == TRUE) %>%
    count(plo_id, plo_name) %>%
    mutate(
      proportion = n / sum(n),
      expected_proportion = 0.25,  # 4 PLOs = 25% each
      balance_deviation = abs(proportion - expected_proportion),
      balance_score = 1 - balance_deviation
    ) %>%
    arrange(desc(balance_score))
  
  # Calculate overall balance
  overall_balance <- plo_balance %>%
    summarise(
      avg_balance = mean(balance_score),
      balance_level = case_when(
        avg_balance >= 0.8 ~ "Well Balanced",
        avg_balance >= 0.6 ~ "Moderately Balanced", 
        TRUE ~ "Imbalanced"
      )
    )
  
  # Course-PLO Balance Matrix
  course_plo_balance <- complete_data %>%
    filter(mapped == TRUE) %>%
    count(course_id, course_name_th, plo_id) %>%
    group_by(course_id, course_name_th) %>%
    mutate(
      course_total = sum(n),
      plo_proportion = n / course_total
    ) %>%
    ungroup() %>%
    mutate(course_short = str_trunc(course_name_th, 25))
  
  return(list(
    plo_balance = plo_balance,
    overall_balance = overall_balance,
    course_plo_matrix = course_plo_balance
  ))
}

# 5. Strategic Importance Analysis - การวิเคราะห์ความสำคัญเชิงกลยุทธ์
calculate_strategic_importance <- function(complete_data) {
  
  cat("=== Strategic Importance Analysis ===\n")
  
  # Course Strategic Score
  course_strategic <- complete_data %>%
    filter(mapped == TRUE) %>%
    group_by(course_id, course_name_th) %>%
    summarise(
      total_keyword_score = sum(score, na.rm = TRUE),
      high_value_keywords = sum(score >= 7, na.rm = TRUE),
      plo_coverage = n_distinct(plo_id),
      subplo_coverage = n_distinct(subplo_id),
      clo_count = n_distinct(clo_number),
      .groups = "drop"
    ) %>%
    left_join(courses %>% select(course_id, hours), by = "course_id") %>%
    mutate(
      strategic_score = (total_keyword_score * 0.4) + 
        (high_value_keywords * 5) + 
        (plo_coverage * 10) + 
        (subplo_coverage * 2) + 
        (hours * 0.1),
      score_per_hour = strategic_score / hours,
      importance_rank = row_number(desc(strategic_score)),
      importance_category = case_when(
        strategic_score >= 100 ~ "Critical",
        strategic_score >= 70 ~ "High Priority",
        strategic_score >= 40 ~ "Important",
        TRUE ~ "Supporting"
      ),
      course_short = str_trunc(course_name_th, 30)
    ) %>%
    arrange(desc(strategic_score))
  
  # High-Impact Keywords Analysis
  high_impact_keywords <- complete_data %>%
    filter(mapped == TRUE & !is.na(keyword)) %>%
    group_by(keyword) %>%
    summarise(
      keyword_score = first(score),
      course_reach = n_distinct(course_id),
      clo_impact = n_distinct(course_id, clo_number),
      strategic_impact = keyword_score * course_reach * 0.5 + clo_impact,
      .groups = "drop"
    ) %>%
    filter(keyword_score >= 5) %>%  # เฉพาะ keywords สำคัญ
    mutate(
      impact_rank = row_number(desc(strategic_impact)),
      impact_category = case_when(
        strategic_impact >= 50 ~ "High Impact",
        strategic_impact >= 20 ~ "Medium Impact", 
        TRUE ~ "Low Impact"
      )
    ) %>%
    arrange(desc(strategic_impact))
  
  return(list(
    course_strategic = course_strategic,
    high_impact_keywords = high_impact_keywords
  ))
}

# 6. Comprehensive Metrics Summary
generate_metrics_summary <- function(complete_data) {
  
  cat("=== Generating Comprehensive Metrics Summary ===\n")
  
  # คำนวณตัวชี้วัดทั้งหมด
  coverage_metrics <- calculate_coverage_metrics(complete_data)
  alignment_metrics <- calculate_alignment_strength(complete_data)
  concentration_metrics <- calculate_concentration_index(complete_data)
  balance_metrics <- calculate_balance_metrics(complete_data)
  strategic_metrics <- calculate_strategic_importance(complete_data)
  
  # สร้างสรุปภาพรวม
  summary_stats <- tibble(
    metric_category = c("Coverage", "Alignment", "Balance", "Strategic Value"),
    plo_coverage = coverage_metrics$overall_plo$plo_coverage_pct,
    subplo_coverage = coverage_metrics$overall_subplo$subplo_coverage_pct,
    balance_level = balance_metrics$overall_balance$balance_level,
    concentration_level = concentration_metrics$plo_concentration$concentration_level,
    total_courses = n_distinct(complete_data$course_id),
    total_hours = sum(courses$hours),
    total_mappings = nrow(complete_data %>% filter(mapped == TRUE))
  )
  
  return(list(
    coverage = coverage_metrics,
    alignment = alignment_metrics,
    concentration = concentration_metrics,
    balance = balance_metrics,
    strategic = strategic_metrics,
    summary = summary_stats
  ))
}

# ฟังก์ชันตรวจสอบคุณภาพข้อมูล
validate_complete_data <- function(complete_data) {
  
  cat("=== การตรวจสอบคุณภาพข้อมูล ===\n")
  
  # จำนวนระเบียนทั้งหมด
  total_rows <- nrow(complete_data)
  cat("จำนวนระเบียนทั้งหมด:", total_rows, "\n")
  
  # ตรวจสอบข้อมูลขาดหาย
  missing_subplo <- sum(is.na(complete_data$subplo_id))
  missing_keywords <- sum(is.na(complete_data$keyword))
  cat("ข้อมูล sub-PLO ขาดหาย:", missing_subplo, "ระเบียน\n")
  cat("ข้อมูล keywords ขาดหาย:", missing_keywords, "ระเบียน\n")
  
  # การกระจายตัวของข้อมูล
  course_distribution <- complete_data %>%
    filter(mapped == TRUE) %>%
    count(course_id, course_name_th, sort = TRUE)
  
  subplo_distribution <- complete_data %>%
    filter(mapped == TRUE) %>%
    count(subplo_id, sort = TRUE)
  
  cat("\n=== การกระจายตัวข้อมูล ===\n")
  cat("รายวิชาที่มี mapping มากที่สุด:\n")
  print(head(course_distribution, 3))
  
  cat("\nsub-PLO ที่มี mapping มากที่สุด:\n") 
  print(head(subplo_distribution, 5))
  
  return(list(
    total_rows = total_rows,
    missing_subplo = missing_subplo,
    missing_keywords = missing_keywords,
    course_dist = course_distribution,
    subplo_dist = subplo_distribution
  ))
}

# ฟังก์ชันตรวจสอบความครอบคลุมของ sub-PLO
check_subplo_coverage <- function() {
  coverage <- clo_subplo_mapping %>%
    filter(mapped == TRUE) %>%
    distinct(subplo_id) %>%
    nrow()
  
  total_subplo <- nrow(subplo_info)
  coverage_pct <- round(coverage / total_subplo * 100, 1)
  
  cat("=== การครอบคลุม Sub-PLO ===\n")
  cat("Sub-PLO ที่ถูกครอบคลุม:", coverage, "จาก", total_subplo, "\n")
  cat("ร้อยละการครอบคลุม:", coverage_pct, "%\n")
}

# ==================== 9. การสร้างและตรวจสอบข้อมูล ====================

# สร้าง complete dataset
complete_dataset <- create_complete_dataset()

# ตรวจสอบคุณภาพข้อมูล
validation_result <- validate_complete_data(complete_dataset)

# สร้างข้อมูลสำหรับ visualization
sankey_data <- create_sankey_data(complete_dataset)
heatmap_data <- create_heatmap_data(complete_dataset)
keyword_summary <- create_keyword_summary(complete_dataset)

# แสดงสรุปข้อมูล
summarize_course_data()
check_subplo_coverage()

cat("\n=== ข้อมูลสำหรับ Visualization ===\n")
cat("Sankey nodes:", nrow(sankey_data$nodes), "\n")
cat("Sankey links:", nrow(sankey_data$links), "\n")
cat("Heatmap data points:", nrow(heatmap_data), "\n")
cat("Keywords summary:", nrow(keyword_summary), "\n")

# ตัวอย่างการใช้งาน
cat("\n=== ตัวอย่างข้อมูล ===\n")
cat("Complete dataset (first 5 rows):\n")
print(head(complete_dataset, 5))

cat("\nTop 5 keywords by score:\n")
print(head(keyword_summary %>% select(keyword, score, score_category, course_count), 5))

cat("\nHeatmap data sample:\n")
print(head(heatmap_data %>% filter(intensity > 0) %>% select(course_short, subplo_id, clo_count, intensity), 5))

# ==================== 10. การรันการวิเคราะห์ ====================

# สร้างตัวชี้วัดทั้งหมด
metrics_analysis <- generate_metrics_summary(complete_dataset)

cat("\n=== สรุปผลการวิเคราะห์ตัวชี้วัด ===\n")
cat("PLO Coverage:", metrics_analysis$coverage$overall_plo$plo_coverage_pct, "%\n")
cat("Sub-PLO Coverage:", metrics_analysis$coverage$overall_subplo$subplo_coverage_pct, "%\n")
cat("Balance Level:", metrics_analysis$balance$overall_balance$balance_level, "\n")
cat("Concentration Level:", metrics_analysis$concentration$plo_concentration$concentration_level, "\n")

cat("\nTop 3 Strategic Courses:\n")
print(head(metrics_analysis$strategic$course_strategic %>% 
             select(course_short, strategic_score, importance_category), 3))

cat("\nTop 5 High-Impact Keywords:\n") 
print(head(metrics_analysis$strategic$high_impact_keywords %>%
             select(keyword, keyword_score, course_reach, impact_category), 5))