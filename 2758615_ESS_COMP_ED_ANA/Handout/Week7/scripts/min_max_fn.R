## 1. สร้าง function เพื่อคำนวณ min-max normalized score
## function ใน R, python คือชุดคำสั่งสำเร็จรูปที่ใช้ซ้ำ ๆ ได้ ในงานที่กำหนด
## ส่วนประกอบของ function ประกอบด้วย input argument --> f(x) --> output
## ลองสร้างฟังก์ชันสำหรับ normalized ข้อมูล
normalized <- function(x)
{
  min_max <- (x-min(x))/(max(x)-min(x))
  return(min_max)
}
normalized
normalized(data$choose_method)