library(tidyverse)
## install.packages("readxl")
library(readxl)
messy_data <- read_excel(path = "Week3/messydata.xlsx")
messy_data
## ตัวแปรที่ควรจะมีในชุดข้อมูลประกอบด้วย
## 1. วิธีสอน ที่มี 2 วิธี (ค่า) ได้แก่ Lecture และ PBL
## 2. เวลา ที่มี 2 จุดเวลา (ค่า) ได้แก่ pre และ post
## 3. คะแนน ที่เป็นตัวแปรต่อเนื่อง ตัวเลข

messy_data |> 
  pivot_longer(
    cols = 2:5,
    names_to = c("method_time"),
    values_to = "score"
  ) |> 
separate(method_time, into = c("method", "time"), sep = "[.]") |> View()

### สร้าง boxplot
### แกน X เป็นวิธีการสอน
### สี fill เป็น เวลา
### แกน Y เป็น คะแนน

ggplot(aes(x= metd, y= score, fill = time)) +
  geom_boxplot() +
  labs(x = "Method", y = "Score", fill = "Time") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  ggtitle("Boxplot of Scores by Teaching Method and Time")))


