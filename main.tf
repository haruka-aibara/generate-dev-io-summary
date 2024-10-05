module "iam" {
  source = "./modules/iam"
}

module "sqs" {
  source = "./modules/sqs"
  name   = var.queue_name
}

module "sns" {
  source = "./modules/sns"
  name   = var.topic_name
}

module "scraper_lambda" {
  source                 = "./modules/lambda"
  filename               = data.archive_file.lambda_scraper.output_path
  function_name          = "dev_io_scraper"
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.12"
  role_arn               = module.iam.lambda_role_arn
  timeout                = 30
  layer_zip_path         = data.archive_file.lambda_layer.output_path
  layer_source_code_hash = data.archive_file.lambda_layer.output_base64sha256
  environment_variables = {
    QUEUE_URL = module.sqs.queue_url
  }
}

module "summarizer_lambda" {
  source                 = "./modules/lambda"
  filename               = data.archive_file.lambda_summarizer.output_path
  function_name          = "dev_io_summarizer"
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.12"
  role_arn               = module.iam.lambda_role_arn
  timeout                = 300
  layer_zip_path         = data.archive_file.lambda_layer.output_path
  layer_source_code_hash = data.archive_file.lambda_layer.output_base64sha256

  environment_variables = {
    QUEUE_URL = module.sqs.queue_url
    TOPIC_ARN = module.sns.topic_arn
  }
}

# Scraper resources
resource "aws_cloudwatch_event_rule" "daily_scraper" {
  name                = "dev_io_daily_scraper"
  description         = "Triggers the Dev.to scraper Lambda function daily"
  schedule_expression = "cron(25 21 * * ? *)" # Runs daily at 6:25 AM JST
}

resource "aws_cloudwatch_event_target" "scraper_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_scraper.name
  target_id = "ScraperLambda"
  arn       = module.scraper_lambda.function_arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_scraper" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.scraper_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_scraper.arn
}

# Summarizer resources
resource "aws_cloudwatch_event_rule" "daily_summarizer" {
  name                = "dev_io_daily_summarizer"
  description         = "Triggers the Dev.to summarizer Lambda function daily"
  schedule_expression = "cron(30 21 * * ? *)" # Runs daily at 6:30 AM JST
}

resource "aws_cloudwatch_event_target" "summarizer_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_summarizer.name
  target_id = "SummarizerLambda"
  arn       = module.summarizer_lambda.function_arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_summarizer" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.summarizer_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_summarizer.arn
}

module "chatbot_slack" {
  source             = "./modules/chatbot"
  configuration_name = local.app_name
  slack_channel_id   = local.slack_channel_id
  slack_workspace_id = local.slack_workspace_id
  sns_topic_arns     = [module.sns.topic_arn]
  logging_level      = "NONE"
}
