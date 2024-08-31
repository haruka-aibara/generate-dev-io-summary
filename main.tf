module "summarizer_lambda" {
  source        = "./modules/lambda"
  function_name = "dev_io_summarizer"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_functions/summarizer/lambda_function.zip"
  role_arn      = module.iam.lambda_role_arn

  environment_variables = {
    QUEUE_URL = module.sqs.queue_url
    TOPIC_ARN = module.sns.topic_arn
  }
}

resource "aws_cloudwatch_event_rule" "daily_scraper" {
  name                = "dev_io_daily_scraper"
  description         = "Triggers the Dev.to scraper Lambda function daily"
  schedule_expression = "cron(0 1 * * ? *)" # Runs daily at 1:00 AM UTC
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
