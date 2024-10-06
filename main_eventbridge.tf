# Scraper resources
resource "aws_cloudwatch_event_rule" "daily_scraper" {
  name                = "${local.scraper_name}_daily_invoke"
  description         = "Triggers ${local.scraper_name} lambda function daily"
  schedule_expression = local.scraper_schedule
}

resource "aws_cloudwatch_event_target" "scraper_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_scraper.name
  target_id = local.scraper_name
  arn       = aws_lambda_function.scraper.arn
}

# Summarizer resources
resource "aws_cloudwatch_event_rule" "daily_summarizer" {
  name                = "${local.summarizer_name}_daily_invoke"
  description         = "Triggers ${local.summarizer_name} lambda function daily"
  schedule_expression = local.summarizer_schedule
}

resource "aws_cloudwatch_event_target" "summarizer_lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_summarizer.name
  target_id = local.summarizer_name
  arn       = aws_lambda_function.summarizer.arn
}
