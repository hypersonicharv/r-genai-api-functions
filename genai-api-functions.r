library(httr)
library(jsonlite)

# REMEMBER TO ADD YOUR API KEYS
YOUR_OPENAI_API_KEY <- "sk-1"
YOUR_ANTHROPIC_API_KEY <- "sk-2"

# Function to prompt the GPT-4-Turbo API using a string, "prompt"
# Returns a list with the text response from the model, plus the number of input and output tokens used
# Includes the temperature parameter
prompt_gpt4_turbo <- function(prompt, openai_api_key) {
 response <- POST(
  url = "https://api.openai.com/v1/chat/completions", 
  add_headers(Authorization = paste("Bearer", openai_api_key)),
  content_type_json(),
  encode = "json",
  body = list(
   model = "gpt-4-1106-preview",
   temperature = 0.8,
   messages = list(list(role = "user", content = prompt))
  )
 )
 content <- httr::content(response, as = "text")
 json_data <- jsonlite::fromJSON(content, flatten = TRUE)
 gpt4_response <- json_data$choices$message.content
 input_tokens <- json_data$usage$prompt_tokens
 completion_tokens <- json_data$usage$completion_tokens
  
 return(list(gpt4_response, input_tokens, completion_tokens))
}

# Function to prompt the Claude 3 Opus API using a string, "prompt"
# Returns a list with the text response from the model, plus the number of input and output tokens used
# Note that the headers and format of the JSON package are different to the OpenAI API; you have to unbox the list.
prompt_claude <- function(prompt, claude_api_key) {
 response <- POST(
  url = "https://api.anthropic.com/v1/messages", 
  add_headers(`x-api-key` = claude_api_key, `anthropic-version` = "2023-06-01",`content-type` = "application/json"),
  encode = "json",
  body = toJSON(list(
   model = "claude-3-opus-20240229",
   max_tokens = 1024,
   messages = list(list(role = "user", content = prompt))
  ),auto_unbox = TRUE)
 )
 content <- httr::content(response, as = "text")
 json_data <- jsonlite::fromJSON(content, flatten = TRUE)
 claude_response <- json_data$content$text
 input_tokens <- json_data$usage$input_tokens
 completion_tokens <- json_data$usage$output_tokens
  
 return(list(claude_response, input_tokens, completion_tokens))
}

# Try out the APIs
gpt4 <- prompt_gpt4_turbo("Hello GPT-4!", YOUR_OPENAI_API_KEY)
cat(gpt4[[1]]) # Display the text of the response
cost <- (0.01*gpt4[[2]]/1000) + (0.03*gpt4[[3]]/1000) # Cost in $

c3 <- prompt_claude3("Hello Claude!", YOUR_ANTHROPIC_API_KEY)
cat(c3[[1]]) # Display the text of the response
cost <- (15*c3[[2]]/1000000)+(75*c3[[3]]/1000000) # Cost in $
