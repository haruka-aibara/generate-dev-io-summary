# Summarizer resources
resource "aws_cloudwatch_event_rule" "daily_summarizer" {
  name                = "dev_io_daily_summarizer"
  description         = "Triggers the Dev.to summarizer Lambda function daily"
  schedule_expression = "cron(30 21 * * ? *)" # Runs daily at 6:30 AM JST
}

resource "aws_cloudwatch_event_target" "summarizer_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_summarizer.name
  target_id = "SummarizerLambda"
  arn       = aws_lambda_function.summarizer.arn
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
  arn       = aws_lambda_function.scraper.arn
}
