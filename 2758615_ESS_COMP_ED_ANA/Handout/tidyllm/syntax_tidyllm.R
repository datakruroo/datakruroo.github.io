install.packages("tidyllm")
library(tidyverse)
library(tidyllm)

tidyllm::
### เรามีโมเดลอะไรบ้าง?
ollama_list_models()


## request
response <- llm_message(
  .system_prompt = "คุณคือ อ.อี่ ผู้เชี่ยวชาญสถิติแห่งชาติ  ทุกครั้งที่ตอบต้องแนะนำตัวก่อนว่า `ผมคือ อ.อี่ ผู้เชี่ยวชาญด้านสถิติแห่งชาติจะขอตอบ... อนึ่งว่า เมื่อตอบเสร็จให้ลงท้ายว่า ชะเอิงเอิงเอย` ตอบภาษาไทยเท่านั้น",
  .prompt = "สวัสดี ช่วยอธิบาย correชlation หน่อย"
) %>% 
## ส่ง request ไปยังโมเดลภาษา
chat(ollama(),
       .model = "llama3:latest",
       .temperature = 0.5)
## ดูผลลัพธ์
response


tibble(
prompt = 1,  
user_prompt = "สวัสดี ช่วยอธิบาย correlation หน่อย",
answer = get_reply(response)
)


## จะใช้่เมื่อมีการกำหนด Schema <-- โครงสร้าง JSON สำหรับส่งออกผลลัพธ์
get_reply_data(response)

#### ------------------

tibble(
  prompt = 1,  
  user_prompt = "สวัสดี ช่วยอธิบาย correlation หน่อย",
  answer = get_reply(response)
)

# สร้าง schema สำหรับการวิเคราะห์ sentiment
sentiment_schema <- tidyllm_schema(
  name = "sentiment_analysis",
  sentiment_score = field_dbl("ค่าคะแนน sentiment (-1 ถึง 1)"),
  sentiment_label = field_chr("ป้ายกำกับ: positive, negative, neutral"),
  confidence = field_dbl("ระดับความมั่นใจ (0 ถึง 1)"),
  reasoning = field_chr("เหตุผลการตัดสินใจ")
)

sentiment_response <- llm_message(
  .system_prompt = "วิเคราะห์ sentiment ของข้อความต่อไปนี้",
  .prompt = "วันนี้อากาศดีมาก ไปเที่ยวสนุกมากเลย!"
)
# ใช้ schema ในการเรียก LLM


data <- read_csv("/Users/choat/Downloads/reviews_chot_stat.csv")

positive <- data$positive
output <- tibble()

for (i in 1:5)
{
### message = system + user prompt
msg <- tibble(
    role = c("system", "user"),
    content = c(
      "วิเคราะห์ sentiment ของข้อความต่อไปนี้",
      positive[i]
    )
  )

response <-msg %>% df_llm_message() %>% 
  chat(openai(),
       .model = "gpt-4o-mini",
       .temperature = 0.2,
       .json_schema = sentiment_schema)
 
result <- sentiment_response %>% get_reply_data()

res <- tibble(
  sentiment_score = result$sentiment_score,
  sentiment_label = result$sentiment_label,
  confidence = result$confidence,
  reasoning = result$reasoning
)
output <- output %>% bind_rows(res)

}








result <- sentiment_response %>% get_reply_data()

tibble(
sentiment_score = result$sentiment_score,
sentiment_label = result$sentiment_label,
confidence = result$confidence,
reasoning = result$reasoning
)








result <- messages %>% 
  chat(openai(), 
       .model = "gpt-4o-mini",
       .json_schema = sentiment_schema) %>%
  get_reply_data()

# ได้ structured data พร้อมใช้
str(result)







