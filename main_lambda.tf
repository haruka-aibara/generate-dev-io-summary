module "scraper_lambda" {
  source                 = "./modules/lambda"
  filename               = data.archive_file.lambda_scraper.output_path
  function_name          = "dev_io_scraper"
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.12"
  role                   = aws_iam_role.lambda.arn
  timeout                = 30
  layer_zip_path         = data.archive_file.lambda_layer.output_path
  layer_source_code_hash = data.archive_file.lambda_layer.output_base64sha256
  environment_variables = {
    QUEUE_URL = aws_sqs_queue.this.url
    MAIN_URL  = local.developers_io_url
  }
}

module "summarizer_lambda" {
  source                 = "./modules/lambda"
  filename               = data.archive_file.lambda_summarizer.output_path
  function_name          = "dev_io_summarizer"
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.12"
  role                   = aws_iam_role.lambda.arn
  timeout                = 300
  layer_zip_path         = data.archive_file.lambda_layer.output_path
  layer_source_code_hash = data.archive_file.lambda_layer.output_base64sha256

  environment_variables = {
    QUEUE_URL = aws_sqs_queue.this.url
    TOPIC_ARN = aws_sns_topic.this.arn
    MODEL_ID  = local.bedrock_model_id
  }
}



resource "aws_lambda_permission" "allow_cloudwatch_to_call_scraper" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.scraper_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_scraper.arn
}



resource "aws_lambda_permission" "allow_cloudwatch_to_call_summarizer" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.summarizer_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_summarizer.arn
}

