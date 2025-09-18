source('data/generate_dataset.R')

# ทดสอบสร้าง heatmap แบบง่าย
cat("Testing simple heatmap creation...\n")

# เตรียมข้อมูล heatmap
simple_heatmap_data <- complete_dataset %>%
  filter(mapped == TRUE) %>%
  group_by(course_id, course_name_th, plo_id) %>%
  summarise(
    connection_strength = n_distinct(clo_number, subplo_id),
    keyword_intensity = sum(score, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    combined_strength = connection_strength + (keyword_intensity / 10),
    course_short = str_trunc(course_name_th, 30),
    plo_label = paste("PLO", plo_id)
  )

cat("Simple heatmap data structure:\n")
print(head(simple_heatmap_data, 10))

cat("\nNumber of rows in heatmap data:", nrow(simple_heatmap_data), "\n")
cat("Unique courses:", n_distinct(simple_heatmap_data$course_id), "\n")
cat("Unique PLOs:", n_distinct(simple_heatmap_data$plo_id), "\n")

# ตรวจสอบว่ามี course_name_th หรือไม่
cat("\nColumn names in heatmap data:\n")
print(names(simple_heatmap_data))

cat("\nTest completed successfully!\n")
