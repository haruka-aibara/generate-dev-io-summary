## For Chatbot
resource "aws_iam_role" "chatbot" {
  name               = "${local.project_name}-chatbot-role"
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
    resources = [aws_sns_topic.this.arn]
  }
}

resource "aws_iam_policy" "chatbot" {
  name        = "${local.project_name}-chatbot-policy"
  description = "${local.project_name}-chatbot-policy"
  policy      = data.aws_iam_policy_document.chatbot.json
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot.arn
}

# For Scraper Lambda
data "aws_iam_policy_document" "scraper_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "scraper" {
  name               = "${local.scraper_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.scraper_lambda_assume_role.json
}

data "aws_iam_policy_document" "scraper" {
  statement {
    sid    = "sqs"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]
    resources = [aws_sqs_queue.this.arn]
  }
  statement {
    sid    = "logs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.scraper.arn}:log-stream:*",
    ]
  }
}

resource "aws_iam_policy" "scraper" {
  name        = "${local.scraper_name}-lambda-policy"
  description = "${local.scraper_name}-lambda-policy"
  policy      = data.aws_iam_policy_document.scraper.json
}

resource "aws_iam_role_policy_attachment" "scraper" {
  role       = aws_iam_role.scraper.name
  policy_arn = aws_iam_policy.scraper.arn
}

# For Summarizer Lambda
data "aws_iam_policy_document" "summarizer_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "summarizer" {
  name               = "${local.summarizer_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.summarizer_lambda_assume_role.json
}

data "aws_iam_policy_document" "summarizer" {
  statement {
    sid    = "sns"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [aws_sns_topic.this.arn]
  }
  statement {
    sid    = "bedrock"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
    ]
    resources = ["arn:aws:bedrock:*::foundation-model/${local.bedrock_model_id}"]
  }
  statement {
    sid    = "sqs"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
    ]
    resources = [aws_sqs_queue.this.arn]
  }
  statement {
    sid    = "logs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.summarizer.arn}:log-stream:*"
    ]
  }
}

resource "aws_iam_policy" "summarizer" {
  name        = "${local.summarizer_name}-lambda-policy"
  description = "${local.summarizer_name}-lambda-policy"
  policy      = data.aws_iam_policy_document.summarizer.json
}

resource "aws_iam_role_policy_attachment" "summarizer" {
  role       = aws_iam_role.summarizer.name
  policy_arn = aws_iam_policy.summarizer.arn
}
