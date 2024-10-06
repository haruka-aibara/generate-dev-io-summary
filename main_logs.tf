resource "aws_cloudwatch_log_group" "scraper" {
  name              = "/aws/lambda/dev_io_scraper"
  retention_in_days = 1

}

resource "aws_cloudwatch_log_group" "summarizer" {
  name              = "/aws/lambda/dev_io_summarizer"
  retention_in_days = 1

}

import {
  id = "/aws/lambda/dev_io_scraper"
  to = aws_cloudwatch_log_group.scraper
}

import {
  id = "/aws/lambda/dev_io_summarizer"
  to = aws_cloudwatch_log_group.summarizer
}
