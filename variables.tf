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

variable "slack_channel_id" {
  type        = string
  description = "The ID of the Slack channel"
}

variable "slack_workspace_id" {
  type        = string
  description = "The ID of the Slack workspace"
}

variable "TFC_AWS_PROVIDER_AUTH" {
  type = string
}

variable "TFC_AWS_RUN_ROLE_ARN" {
  type = string
}
