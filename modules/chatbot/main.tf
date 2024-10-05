resource "aws_chatbot_slack_channel_configuration" "this" {
  configuration_name    = var.configuration_name
  slack_channel_id      = var.slack_channel_id
  slack_team_id         = var.slack_workspace_id
  iam_role_arn          = aws_iam_role.chatbot.arn
  sns_topic_arns        = var.sns_topic_arns
  logging_level         = var.logging_level
  guardrail_policy_arns = [aws_iam_policy.chatbot.arn]
}

resource "aws_iam_role" "chatbot" {
  name               = "${var.configuration_name}-chatbot-role"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume_role.json
}

data "aws_iam_policy_document" "chatbot_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "chatbot" {
  statement {
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:ListSubscriptionsByTopic"
    ]
    resources = var.sns_topic_arns
  }
}

resource "aws_iam_policy" "chatbot" {
  name        = "${var.configuration_name}-chatbot-policy"
  description = "${var.configuration_name}-chatbot-policy"
  policy      = data.aws_iam_policy_document.chatbot.json
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot.arn
}
