# Lambda Layer用のzipファイルのアーカイブを作成
data "archive_file" "lambda_layer_scraper" {
  type        = "zip"
  source_dir  = "lambda_functions/lambda_layer"
  output_path = "lambda_functions/lambda_layer/lambda_layer.zip"
}

# Lambda Layer用のzipファイルのアーカイブを作成
data "archive_file" "lambda_layer_summarizer" {
  type        = "zip"
  source_dir  = "lambda_functions/lambda_layer"
  output_path = "lambda_functions/lambda_layer/lambda_layer.zip"
}

# Lambda関数のコードをzip化
data "archive_file" "lambda_scraper" {
  type        = "zip"
  source_dir  = "lambda_functions/scraper"
  output_path = "lambda_functions/scraper/lambda_function.zip"
}

# Lambda関数のコードをzip化
data "archive_file" "lambda_summarizer" {
  type        = "zip"
  source_dir  = "lambda_functions/summarizer"
  output_path = "lambda_functions/summarizer/lambda_function.zip"
}
