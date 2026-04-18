importing_data <- function(url){
data <- read_csv(url)
data <- data |> 
  select(-2) |> 
  rename(student_id = 1) |> 
  select(-contains("onsite")) |>
  rename(sch_type = 2, sch_location = 3, 
        total_subject = 4, 
        online_subject = `จำนวนรายวิชาonline`,
        sch_ready = `ระดับความพร้อมสถานศึกษา`,
        teacher_age = `อายุเฉลี่ยผู้สอน`,
        teacher_it_comp = `ภาพรวมความสามารถในการใช้สื่อเทคโนโลยีของผู้สอน`,
        student_gender = `เพศผู้เรียน`,
        student_level = `ระดับชั้น`,
        student_location = `ภูมิลำเนา`,
        student_learning_style = `สไตล์การเรียนที่ชอบ`,
        student_internet = `ความพร้อมของinternet`,
        home_climate = `บรรยากาศที่พักอาศัย`,
        student_it_comp = `ความสามารถผู้เรียนในการใช้เทคโนโลยี`,
        student_learning_attitude = `ความคิดเห็นต่อการเรียน`,
        stress_online = `ความเครียดขณะเรียนonline`,
      )
return(data)
}



