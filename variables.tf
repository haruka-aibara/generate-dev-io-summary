variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "dev_io_article_queue"
}

variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "dev_io_summary_topic"
}