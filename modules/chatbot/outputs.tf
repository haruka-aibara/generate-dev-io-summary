output "chatbot_configuration_arn" {
  value       = aws_chatbot_slack_channel_configuration.this.chat_configuration_arn
  description = "ARN of the Slack channel configuration."
}

output "slack_channel_name" {
  value       = aws_chatbot_slack_channel_configuration.this.slack_channel_name
  description = "Name of the Slack channel."
}

output "slack_team_name" {
  value       = aws_chatbot_slack_channel_configuration.this.slack_team_name
  description = "Name of the Slack team."
}

output "tags_all" {
  value       = aws_chatbot_slack_channel_configuration.this.tags_all
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
}
