library(tidyverse)
## 1. importing data
teacher_salary_data <- read_csv("01_data/TeacherSalaryData.csv",
                                show_col_types = FALSE) |>  
## 2. naming variables
  rename(
    teacher_id = 1,
    teacher_position = 2,
    yrs_since_phd = 4,
    yrs_service = 5,
    gender = 6
  ) |> 
## 3. convert character to factor
  mutate(
    teacher_position = factor(teacher_position,
                              levels= c("AsstProf", 
                                        "AssocProf", 
                                        "Prof")),
    discipline = factor(discipline,
                        levels = c("A","B"),
                        labels = c("Science","Social_Science")),
    gender = factor(gender)
  ) |> 
## 4. define missing code
  mutate(
    yrs_since_phd = na_if(yrs_since_phd, -999),
    salary = na_if(salary, -999)
  ) |> 
  na.omit()

cat("output ที่ส่งออกจาก function นี้คือ teacher_salary_data")












