variable "configuration_name" {
  type        = string
  description = "The name of the configuration"
}

variable "slack_channel_id" {
  type        = string
  description = "The ID of the Slack channel"
}

variable "slack_workspace_id" {
  type        = string
  description = "The ID of the Slack workspace"
}

variable "sns_topic_arns" {
  type        = list(string)
  description = "The ARNs of the SNS topics"
  default     = []
}

variable "logging_level" {
  type        = string
  description = "Specifies the logging level. Can be ERROR, INFO, or NONE"
  default     = "NONE"
}
