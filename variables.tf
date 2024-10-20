variable "env" {
  description = "environment"
  type        = string
  default     = "production"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "slack_channel_id" {
  type        = string
  description = "The ID of the Slack channel"
}

variable "slack_workspace_id" {
  type        = string
  description = "The ID of the Slack workspace"
}
