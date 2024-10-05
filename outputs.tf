output "scraper_lambda_arn" {
  description = "ARN of the scraper Lambda function"
  value       = module.scraper_lambda.function_arn
}

output "summarizer_lambda_arn" {
  description = "ARN of the summarizer Lambda function"
  value       = module.summarizer_lambda.function_arn
}


