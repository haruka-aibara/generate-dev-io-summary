locals {
  app_name           = "generate-dev-io-summary"
  developers_io_url  = "https://dev.classmethod.jp"
  bedrock_model_id   = "anthropic.claude-v2:1"
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id

}
