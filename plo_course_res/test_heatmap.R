source('data/generate_dataset.R')
source('analysis/visualization.R')

# ทดสอบ heatmap function เท่านั้น
tryCatch({
  cat("Testing heatmap function...\n")
  heatmap_plot <- create_course_plo_heatmap(complete_dataset)
  cat("Success: Heatmap function works!\n")
}, error = function(e) {
  cat("Error in heatmap function:\n")
  print(e$message)
  cat("\nDebugging - checking data structure:\n")
  print(str(complete_dataset))
})
