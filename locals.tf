locals {
  project_name        = "generate-dev-io-summary"
  git_repository_name = "https://github.com/haruka-aibara/generate-dev-io-summary"
  scraper_name        = "${local.project_name}_scraper"
  scraper_schedule    = "cron(25 21 * * ? *)" # 6:25 AM JST
  summarizer_name     = "${local.project_name}_summarizer"
  summarizer_schedule = "cron(30 21 * * ? *)" # 6:30 AM JST
  developers_io_url   = "https://dev.classmethod.jp"
  bedrock_model_id    = "anthropic.claude-v2:1"
  slack_channel_id    = var.slack_channel_id
  slack_workspace_id  = var.slack_workspace_id

  default_tags = {
    Owner       = "haruka-aibara"
    Terraform   = true
    Environment = var.env
    Project     = local.project_name
    Repository  = local.git_repository_name
  }
}
