p <- teacher_salary_data |> 
  ggplot(aes(x = discipline, y = salary))+
  geom_boxplot(aes(fill = discipline))+
  theme_light()+
  xlab("")+
  ylab("เงินเดือนอาจารย์มหาวิทยาลัย \n")+
  theme(text = element_text(family = "ChulaCharasNew"),
        panel.grid = element_blank(),
        legend.position = "none")+
  ggtitle("Salary by Discipline")

print(p)
