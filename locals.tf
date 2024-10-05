locals {
  app_name           = "generate-dev-io-summary"
  developers_io_url  = "https://dev.classmethod.jp"
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  bedrock_model_id   = "anthropic.claude-v2:1"
}
