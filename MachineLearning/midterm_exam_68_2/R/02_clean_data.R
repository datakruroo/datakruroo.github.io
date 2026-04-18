clean_data <- function(data) {
cleaned_data <- data |> 
  mutate(across(where(is.character), as.factor)) |>
  mutate(sch_type = fct_relevel(sch_type, c("โรงเรียนมัธยมศึกษา", "มหาวิทยาลัย"))) |> 
  mutate(online_subject_prop = online_subject / total_subject, .before = total_subject,
  .keep = "unused") |> 
  mutate(across(c("sch_ready","teacher_it_comp", 
                  "student_internet", "home_climate",
                  "student_it_comp", "student_learning_attitude",
                  "stress_online"), factor)) |> 
  mutate(home_climate = factor(home_climate,
                            levels = c(1,2),
                            labels = c("ดี","ไม่ดี"))) |> 
  mutate(student_internet = factor(student_internet,
                            levels = c(0,1),
                            labels = c("ไม่พร้อม","พร้อม"))) |> 
  mutate(interaction_online = (interaction.online1 + interaction.online2 + interaction.online3)/3,
         .before = interaction.online1, .keep = "unused") |> 
  mutate(outcome_online = (20*outcome.online1 + 20*outcome.online2 + 20*outcome.online3 + outcome.online4)/4,
         .before = outcome.online1, .keep = "unused")

return(cleaned_data)
}

