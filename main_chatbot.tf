resource "aws_chatbot_slack_channel_configuration" "this" {
  configuration_name          = local.app_name
  iam_role_arn                = aws_iam_role.chatbot.arn
  slack_channel_id            = local.slack_channel_id
  slack_team_id               = local.slack_workspace_id
  guardrail_policy_arns       = [aws_iam_policy.chatbot.arn]
  logging_level               = "NONE"
  sns_topic_arns              = [aws_sns_topic.this.arn]
  tags                        = null
  user_authorization_required = false
}
