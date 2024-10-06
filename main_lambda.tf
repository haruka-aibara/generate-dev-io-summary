resource "aws_lambda_layer_version" "scraper" {
  filename                 = data.archive_file.lambda_layer.output_path
  layer_name               = "dev_io_scraper_layer"
  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["x86_64"]
  description              = "Lambda layer for dev_io_scraper"
  source_code_hash         = data.archive_file.lambda_layer.output_base64sha256
}

resource "aws_lambda_function" "scraper" {
  function_name = "dev_io_scraper"
  role          = aws_iam_role.lambda.arn

  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  layers           = [aws_lambda_layer_version.scraper.arn]
  source_code_hash = filebase64sha256(data.archive_file.lambda_scraper.output_path)
  filename         = data.archive_file.lambda_scraper.output_path
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.this.url
      MAIN_URL  = local.developers_io_url
    }
  }
}

resource "aws_lambda_layer_version" "summarizer" {
  filename                 = data.archive_file.lambda_layer.output_path
  layer_name               = "dev_io_summarizer_layer"
  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["x86_64"]
  description              = "Lambda layer for dev_io_summarizer"
  source_code_hash         = data.archive_file.lambda_layer.output_base64sha256
}

resource "aws_lambda_function" "summarizer" {
  function_name = "dev_io_summarizer"
  role          = aws_iam_role.lambda.arn

  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 300
  layers           = [aws_lambda_layer_version.summarizer.arn]
  source_code_hash = filebase64sha256(data.archive_file.lambda_summarizer.output_path)
  filename         = data.archive_file.lambda_summarizer.output_path
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.this.url
      TOPIC_ARN = aws_sns_topic.this.arn
      MODEL_ID  = local.bedrock_model_id
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_scraper" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scraper.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_scraper.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_summarizer" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.summarizer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_summarizer.arn
}

