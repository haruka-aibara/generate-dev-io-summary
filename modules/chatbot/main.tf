resource "aws_chatbot_slack_channel_configuration" "this" {
  configuration_name = var.configuration_name
  slack_channel_id   = var.slack_channel_id
  slack_team_id      = var.slack_workspace_id
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  sns_topic_arns     = var.sns_topic_arns
  logging_level      = var.logging_level
}

resource "aws_iam_role" "chatbot_role" {
  name = "${var.configuration_name}-chatbot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "chatbot_policy" {
  name = "${var.configuration_name}-chatbot-policy"
  role = aws_iam_role.chatbot_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:GetTopicAttributes",
          "sns:SetTopicAttributes",
          "sns:AddPermission",
          "sns:RemovePermission",
          "sns:DeleteTopic",
          "sns:ListSubscriptionsByTopic"
        ]
        Resource = var.sns_topic_arns
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
