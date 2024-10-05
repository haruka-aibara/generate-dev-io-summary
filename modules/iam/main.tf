data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "dev_io_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "sns"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "bedrock"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
    ]
    resources = ["arn:aws:bedrock:*::foundation-model/${var.model_id}"]
  }
  statement {
    sid    = "sqs"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "logs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda" {
  name        = "dev_io_lambda_policy"
  description = "dev_io_lambda_policy"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
