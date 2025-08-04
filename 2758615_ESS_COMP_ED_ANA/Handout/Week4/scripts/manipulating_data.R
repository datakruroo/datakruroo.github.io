library(tidyverse)
library(here)

mytidy_data[,3] ## matrix index
mytidy_data$infect
select(mytidy_data, infect) 

## importing data
mytidy_data <- read_csv(here("Week4/datasets","mytidy2.csv"))
mytidy_data |> 
  rename(student_id = 1) |> 
  select(student_id ,starts_with("stress"), gpax.y2) |> 
  mutate(stress_avg = (stress.1 + stress.2 + stress.3 +
           stress.4 + stress.5)/5)  |> 
  mutate(gpax_cat = ifelse(gpax.y2 < 1.5, "fail", "pass")) |>  ## ตัดแค่ fail, pass
  count(gpax_cat)


mytidy_data <- read_csv(here("Week4/datasets","mytidy2.csv"))
mytidy_data |> 
  rename(student_id = 1) |> 
  select(student_id ,starts_with("stress"), gpax.y2) |> 
  mutate(stress_avg = (stress.1 + stress.2 + stress.3 +
                         stress.4 + stress.5)/5)  |> 
  mutate(gpax_cat = ifelse(gpax.y2 < 1.5, "fail", 
                           ifelse(gpax.y2 >= 1.5 & gpax.y2 < 3, "fair", "good")))  |> 
  count(gpax_cat)


mytidy_data |> 
  rename(student_id = 1) |> 
  select(student_id ,starts_with("stress"), gpax.y2) |> 
  mutate(stress_avg = (stress.1 + stress.2 + stress.3 +
                         stress.4 + stress.5)/5)  |> 
  mutate(gpax_cat = case_when(
    gpax.y2 < 1.5 ~ "fail",
    gpax.y2 >= 1.5 & gpax.y2 < 3 ~ "fair",
    TRUE ~ "good" ## ที่เหลือทั้งหมด
  )) |> 
  mutate(gpax_cat = factor(gpax_cat,
                           levels = c("fail","fair","good"))) |> 
  summary()
count(gpax_cat)

