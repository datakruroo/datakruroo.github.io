# โหลด libraries ที่จำเป็น
library(tidyverse)
library(readr)
library(jsonlite)
library(lubridate)
library(DT)

# อ่านไฟล์ CSV
registrations <- read_csv('/Users/choat/Documents/register/registrations-67e8bd0e9e2150418091b6c9 (6).csv', 
                          locale = locale(encoding = "UTF-8"))

# ตรวจสอบโครงสร้างข้อมูล
glimpse(registrations)

# ฟังก์ชันสำหรับแตกข้อมูล JSON ในคอลัมน์ persons
extract_persons_data <- function(data) {
  # สร้าง tibble เปล่าสำหรับเก็บข้อมูลที่แตกออกมา
  expanded_data <- tibble()
  
  for (i in 1:nrow(data)) {
    # ข้อมูลพื้นฐานของแต่ละ registration
    base_info <- data[i, ] %>% 
      select(-persons)
    
    # พยายาม parse JSON ในคอลัมน์ persons
    if (!is.na(data$persons[i])) {
      tryCatch({
        persons_list <- fromJSON(data$persons[i])
        
        # ถ้า persons_list เป็น data.frame (หรือ list of persons)
        if (is.data.frame(persons_list) || is.list(persons_list)) {
          if (is.data.frame(persons_list)) {
            persons_df <- persons_list
          } else {
            # แปลง list เป็น data.frame
            persons_df <- bind_rows(persons_list)
          }
          
          # รวมข้อมูลพื้นฐานกับข้อมูลของบุคคล
          combined_row <- bind_cols(
            base_info,
            persons_df
          )
          
          expanded_data <- bind_rows(expanded_data, combined_row)
        }
      }, error = function(e) {
        # ถ้า parse JSON ไม่ได้ ให้เก็บข้อมูลพื้นฐานไว้
        expanded_data <<- bind_rows(expanded_data, base_info)
        warning(paste("Cannot parse JSON for row", i, ":", e$message))
      })
    } else {
      # ถ้าไม่มีข้อมูล persons ให้เก็บข้อมูลพื้นฐานไว้
      expanded_data <- bind_rows(expanded_data, base_info)
    }
  }
  
  return(expanded_data)
}

# แตกข้อมูล JSON ออกเป็นตารางธรรมดา
registrations_expanded <- extract_persons_data(registrations)

# ทำความสะอาดข้อมูลและปรับชื่อคอลัมน์ให้เข้าใจง่าย
# ทำความสะอาดข้อมูลและปรับชื่อคอลัมน์ให้เข้าใจง่าย
registrations_clean <- registrations_expanded %>%
  mutate(posterFileUrl = paste0("https://eduticket.edu.chula.ac.th")) 
  

write_excel_csv(registrations_clean, file = "/Users/choat/Documents/register/thai_early_19Jun2025_expanded_clean.csv")

rename("posterFileUrl" = "poster_file_url")
  poster_file_full_url = case_when(
    !is.na(poster_file_url) & poster_file_url != "" ~ paste0("https://eduticket.edu.chula.ac.th/", poster_file_url),
    TRUE ~ NA_character_
  )
  # ปรับปรุงชื่อคอลัมน์ให้อ่านง่าย
  rename_with(
    ~ case_when(
      .x == "gendermalefemaleother" ~ "gender",
      .x == "affiliationschoolorganization" ~ "affiliation",
      .x == "areaofexpertiseorspecialization" ~ "expertise_area",
      .x == "doyouhaveanyexperiencewithaninclusivesociety" ~ "inclusive_society_experience",
      .x == "whyareyouinterestedinthisconference" ~ "conference_interest_reason",
      .x == "whattopicsareyouinterestedinforthenextconferencemeeting" ~ "future_topics_interest",
      .x == "posterFileUrl" ~ "poster_file_url",
      .x == "jobtitle" ~ "job_title",
      .x == "firstName" ~ "first_name",
      .x == "lastName" ~ "last_name",
      TRUE ~ .x
    )
  ) %>%
  # แปลงข้อมูลวันที่
  mutate(
    createdAt = dmy(createdAt),
    updatedAt = dmy(updatedAt),
    paidAt = case_when(
      !is.na(paidAt) ~ dmy(paidAt),
      TRUE ~ as.Date(NA)
    ),
    
    # ปรับปรุงข้อมูลเพิ่มเติม
    paymentStatus = factor(paymentStatus, levels = c("PENDING", "PAID", "CANCELLED")),
    gender = factor(gender),
    
    # สร้างตัวแปรใหม่
    full_name = paste(first_name, last_name, sep = " "),
    days_since_registration = as.numeric(Sys.Date() - createdAt),
    is_paid = paymentStatus == "PAID",
    
    # ทำความสะอาดข้อมูลว่าง
    across(where(is.character), ~ ifelse(.x == "", NA_character_, .x)),
    
    # เพิ่ม URL สำหรับ poster file
    poster_file_full_url = case_when(
      !is.na(poster_file_url) & poster_file_url != "" ~ paste0("https://eduticket.edu.chula.ac.th/", poster_file_url),
      TRUE ~ NA_character_
    )
  ) %>%
  # จัดเรียงคอลัมน์ให้เป็นระเบียบ
  select(
    # ข้อมูลการลงทะเบียน
    id, confirmCode, eventName,
    
    # ข้อมูลส่วนตัว
    prefix, full_name, first_name, last_name, email, mobile,
    
    # ข้อมูลที่อยู่และงาน
    country, affiliation, job_title, gender,
    
    # ข้อมูลความเชี่ยวชาญและความสนใจ
    expertise_area, inclusive_society_experience,
    conference_interest_reason, future_topics_interest,
    
    # ข้อมูลการชำระเงินและวันที่
    paymentStatus, is_paid, createdAt, updatedAt, paidAt,
    days_since_registration,
    
    # ข้อมูลเทคนิค
    stripeSessionId, poster_file_url, poster_file_full_url
  )

# แสดงข้อมูลสรุป
cat("=== สรุปข้อมูลการลงทะเบียนหลังแตก JSON ===\n")
cat("จำนวนผู้ลงทะเบียนทั้งหมด:", nrow(registrations_clean), "\n")
cat("จำนวนที่ชำระเงินแล้ว:", sum(registrations_clean$is_paid, na.rm = TRUE), "\n")
cat("จำนวนที่รอการชำระเงิน:", sum(registrations_clean$paymentStatus == "PENDING", na.rm = TRUE), "\n\n")


# สรุปข้อมูลตามประเทศ
country_summary <- registrations_clean %>%
  count(country, name = "จำนวน") %>%
  arrange(desc(จำนวน))

cat("การกระจายตามประเทศ:\n")
print(country_summary)

# สรุปข้อมูลตามเพศ
gender_summary <- registrations_clean %>%
  count(gender, name = "number") %>%
  mutate(percent= round(number/ sum(number) * 100, 1))

cat("\nการกระจายตามเพศ:\n")
print(gender_summary)

# สรุปข้อมูลตามสถานะการชำระเงิน
payment_summary <- registrations_clean %>%
  count(paymentStatus, name = "number") %>%
  mutate(percent= round(number/ sum(number) * 100, 1))

cat("\nสถานะการชำระเงิน:\n")
print(payment_summary)

# สรุปข้อมูลพื้นที่ความเชี่ยวชาญ
expertise_summary <- registrations_clean %>%
  count(expertise_area, name = "number") %>%
  arrange(desc(number)) %>%
  slice_head(n = 10)  # แสดงแค่ 10 อันดับแรก

cat("\nพื้นที่ความเชี่ยวชาญ (10 อันดับแรก):\n")
print(expertise_summary)

# สร้างตารางแสดงผลแบบ interactive
create_interactive_table <- function(data) {
  data %>%
    select(
      confirmCode, full_name, email, country, job_title, 
      expertise_area, paymentStatus, createdAt
    ) %>%
    DT::datatable(
      options = list(
        pageLength = 15,
        scrollX = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel')
      ),
      caption = "ตารางข้อมูลการลงทะเบียนผู้เข้าร่วม",
      colnames = c(
        "รหัสยืนยัน" = "confirmCode",
        "ชื่อ-นามสกุล" = "full_name", 
        "อีเมล" = "email",
        "ประเทศ" = "country",
        "ตำแหน่งงาน" = "job_title",
        "ความเชี่ยวชาญ" = "expertise_area",
        "สถานะการชำระ" = "paymentStatus",
        "วันที่ลงทะเบียน" = "createdAt"
      )
    ) %>%
    DT::formatDate("createdAt", "toDateString")
}

# สร้างตาราง interactive (เอา comment ออกถ้าต้องการใช้)
# interactive_table <- create_interactive_table(registrations_clean)
# interactive_table

# บันทึกข้อมูลที่แตกแล้ว
write_csv(registrations_clean, "/Users/choat/Documents/register/thai_early_19Jun2025_expanded_clean.csv")

# สร้างไฟล์แยกสำหรับข้อมูลพื้นฐานและข้อมูลส่วนตัว
basic_info <- registrations_clean %>%
  select(id:eventName, paymentStatus:days_since_registration, stripeSessionId)

personal_info <- registrations_clean %>%
  select(id, confirmCode, prefix:future_topics_interest)

write_csv(basic_info, "registration_basic_info.csv")
write_csv(personal_info, "participant_personal_info.csv")

cat("\n=== ไฟล์ที่สร้างขึ้น ===\n")
cat("1. registrations_expanded_clean.csv - ข้อมูลรวมทั้งหมด\n")
cat("2. registration_basic_info.csv - ข้อมูลพื้นฐานการลงทะเบียน\n")
cat("3. participant_personal_info.csv - ข้อมูลส่วนตัวผู้เข้าร่วม\n")

# สร้างฟังก์ชันสำหรับการวิเคราะห์เพิ่มเติม
analyze_registration_patterns <- function(data) {
  list(
    daily_registrations = data %>%
      count(createdAt, name = "registrations") %>%
      arrange(createdAt),
    
    country_distribution = data %>%
      count(country, sort = TRUE),
    
    expertise_distribution = data %>%
      count(expertise_area, sort = TRUE),
    
    payment_status_by_country = data %>%
      count(country, paymentStatus) %>%
      pivot_wider(names_from = paymentStatus, values_from = n, values_fill = 0)
  )
}

# ทำการวิเคราะห์
analysis_results <- analyze_registration_patterns(registrations_clean)

cat("\n=== ผลการวิเคราะห์พิเศษ ===\n")
cat("การลงทะเบียนรายวัน:\n")
print(analysis_results$daily_registrations)

cat("\nสถานะการชำระเงินแยกตามประเทศ:\n")
print(analysis_results$payment_status_by_country)