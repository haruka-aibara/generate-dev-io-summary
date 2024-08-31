output "scraper_lambda_arn" {
  description = "ARN of the scraper Lambda function"
  value       = module.scraper_lambda.function_arn
}

output "summarizer_lambda_arn" {
  description = "ARN of the summarizer Lambda function"
  value       = module.summarizer_lambda.function_arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = module.sqs.queue_url
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.sns.topic_arn
}