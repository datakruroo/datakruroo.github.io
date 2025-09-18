### -- Function to call OpenAI API -- ###
exam_generator_api <- function(prompt, model = "gpt-4o-mini", temp = 0.7, maximum_token = 600)
{
  library(httr)
  library(jsonlite)
  
  ## API key
  api_key <- Sys.getenv("OPENAI_API_KEY")
  
  ## URL
  base_url <- "https://api.openai.com"
  endpoint <- "/v1/chat/completions"
  
  ## สร้าง request
  response <- POST(
    ## 1. URL
    url = paste0(base_url, endpoint),
    
    ## 2. Header
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    
    ## 3. Body
    body = toJSON(list(
      model = model,
      messages = list(
        list(role = "system", content = "คุณคือครูสถิติทำหน้าที่ออกข้อสอบรายวิชาสถิติระดับปริญญาตรี"),
        list(role = "user",   content = prompt )
      ),
      temperature = temp,      # คุมความสุ่ม
      max_tokens  = maximum_token       # จำกัดความยาวคำตอบ
    ), auto_unbox = TRUE),
    
    ## 4. Timeout
    timeout(60)               # รอได้สูงสุด 60 วินาที
  )
}

## Function to extract text from the response
get_llm_text <- function(response) {
  content <- content(response)$choices[[1]]$message$content
  return(content)
}
