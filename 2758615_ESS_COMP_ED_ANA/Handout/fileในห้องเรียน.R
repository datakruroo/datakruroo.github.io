library(tidyverse)

anscombe %>% summary()

anscombe |> 
  summarise(
    mean_x1 = mean(x1),
    sd_x1 = sd(x1),
    min_x1 = min(x1),
    max_x1 = max(x1),
    mean_y1 = mean(y1),
    sd_y1 = sd(y1),
    min_y1 = min(y1),
    max_y1 = max(y1),
    mean_x2 = mean(x2),
    sd_x2 = sd(x2),
    min_x2 = min(x2),
    max_x2 = max(x2)
  )

anscombe |> 
  pivot_longer(cols = everything(),
               names_to = "variables",
               values_to = "value") |> 
  group_by(variables) |> 
  summarise(mean = mean(value),
            sd = sd(value),
            min = min(value),
            q1 = quantile(value, 0.25),
            med = median(value),
            q3 = quantile(value, 0.75),
            p80 = quantile(value, 0.80),
            max = max(value))

anscombe %>%
  pivot_longer(
    cols = everything(),
    names_to = c(".value", "set"),
    names_pattern = "(.)(\\d+)"
  ) %>% 
  ggplot(aes(x = x, y = y))+
  geom_point()+
  geom_smooth(method = "lm",
              se = F)+
  facet_wrap(~set)




##### -----
library(here)
url <- here("Week5", "learning_data2.csv")
data <- read_csv(url)
glimpse(data)

## tidying data
data %>% 
  mutate(student_id = paste0("student",1:385)) %>% 
  glimpse()
  
data %>% 
  ggplot(aes(percent_submit, y= research_score))+
  geom_point()

data %>% 
  select(choose_method, concepts, interpretation, research_score, 
         submit_time, percent_submit, learning_performance, cheat_index) %>% 
  pivot_longer(cols = everything(),
               names_to = "variables",
               values_to = "value") %>% 
  ggplot(aes(x = value))+
  geom_histogram(bins = 30)+
  facet_wrap(~variables, scale = "free_x")




problem_low <- data %>% 
  select(choose_method, concepts, interpretation, research_score, 
         submit_time, percent_submit, learning_performance, cheat_index) %>% 
  filter(is.na(cheat_index)==F) %>% 
  mutate(choose_method = ifelse(choose_method < 50, "yes","no"),
         concepts = ifelse(concepts < 50, "yes","no"),
         interpretation = ifelse(interpretation < 50, "yes","no"),
         research_score = ifelse(research_score < 70, "yes","no"),
         submit_time = ifelse(submit_time > 168, "yes","no"),
         percent_submit = ifelse(percent_submit < 80, "yes","no"),
         learning_performance = ifelse(learning_performance < 50, "yes","no"),
         cheat_index = ifelse(cheat_index > 0.95, "yes","no")) %>% 
  mutate_if(is.character, factor) %>% 
  rename(low_choose_method = choose_method,
         low_concepts = concepts,
         low_interpretation = interpretation,
         low_research_score = research_score,
         late_submit_time = submit_time,
         low_percent_submit = percent_submit,
         low_learning_performance = learning_performance,
         high_cheat_index = cheat_index) %>% 
  filter(low_research_score == "yes") %>%  ## คัดกรองเฉพาะเด็กคะแนนวิจัยต่ำ
  select(-low_research_score) %>% 
  pivot_longer(cols = everything(),
               names_to = "variables",
               values_to = "value") %>% 
  group_by(variables) %>% 
  count(value) %>% 
  filter(value == "yes") %>% 
  select(-value) %>% 
  arrange(desc(n))
  
  

problem_high <- data %>% 
  select(choose_method, concepts, interpretation, research_score, 
         submit_time, percent_submit, learning_performance, cheat_index) %>% 
  filter(is.na(cheat_index)==F) %>% 
  mutate(choose_method = ifelse(choose_method < 50, "yes","no"),
         concepts = ifelse(concepts < 50, "yes","no"),
         interpretation = ifelse(interpretation < 50, "yes","no"),
         research_score = ifelse(research_score < 70, "yes","no"),
         submit_time = ifelse(submit_time > 168, "yes","no"),
         percent_submit = ifelse(percent_submit < 80, "yes","no"),
         learning_performance = ifelse(learning_performance < 50, "yes","no"),
         cheat_index = ifelse(cheat_index > 0.95, "yes","no")) %>% 
  mutate_if(is.character, factor) %>% 
  rename(low_choose_method = choose_method,
         low_concepts = concepts,
         low_interpretation = interpretation,
         low_research_score = research_score,
         late_submit_time = submit_time,
         low_percent_submit = percent_submit,
         low_learning_performance = learning_performance,
         high_cheat_index = cheat_index) %>% 
  filter(low_research_score == "no") %>% ## คัดกรองเฉพาะเด็กคะแนนวิจัยสูง
  select(-low_research_score) %>% 
  pivot_longer(cols = everything(),
               names_to = "variables",
               values_to = "value") %>% 
  group_by(variables) %>% 
  count(value) %>% 
  filter(value == "yes") %>% 
  select(-value) %>% 
  arrange(desc(n))

problem_low %>% 
  inner_join(problem_high, by ="variables")





problem_data <- data %>% 
  select(choose_method, concepts, interpretation, research_score, 
         submit_time, percent_submit, learning_performance, cheat_index) %>% 
  filter(is.na(cheat_index)==F) %>% 
  mutate(choose_method = ifelse(choose_method < 50, "yes","no"),
         concepts = ifelse(concepts < 50, "yes","no"),
         interpretation = ifelse(interpretation < 50, "yes","no"),
         research_score = ifelse(research_score < 70, "yes","no"),
         submit_time = ifelse(submit_time > 168, "yes","no"),
         percent_submit = ifelse(percent_submit < 80, "yes","no"),
         learning_performance = ifelse(learning_performance < 50, "yes","no"),
         cheat_index = ifelse(cheat_index > 0.95, "yes","no")) %>% 
  mutate_if(is.character, factor) %>% 
  rename(low_choose_method = choose_method,
         low_concepts = concepts,
         low_interpretation = interpretation,
         low_research_score = research_score,
         late_submit_time = submit_time,
         low_percent_submit = percent_submit,
         low_learning_performance = learning_performance,
         high_cheat_index = cheat_index)

problem_data %>% 
  group_by(low_research_score, low_choose_method) %>% 
  count()

#### -----
data %>% 
  select(choose_method, concepts, interpretation, research_score, 
         submit_time, percent_submit, learning_performance, cheat_index) %>% 
  filter(is.na(cheat_index)==F) %>% 
  ggplot(aes(x = research_score < 70, y =choose_method))+
  geom_boxplot()
  
  





