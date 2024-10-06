resource "aws_cloudwatch_log_group" "scraper" {
  name              = "/aws/lambda/${local.scraper_name}"
  retention_in_days = 1

}

resource "aws_cloudwatch_log_group" "summarizer" {
  name              = "/aws/lambda/${local.summarizer_name}"
  retention_in_days = 1

}
