# Lambda Layer用のzipファイルのアーカイブを作成
data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "lambda_functions/lambda_layer"
  output_path = "lambda_functions/archive_files/lambda_layer.zip"
  depends_on  = [null_resource.pip_install]
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

# Lambda Layer用のローカルディレクトリを作成
resource "null_resource" "pip_install" {
  triggers = {
    requirements_md5 = filemd5("./requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p lambda_functions/lambda_layer/python
      pip install -r ./requirements.txt -t ./lambda_functions/lambda_layer/python
    EOF
  }
}
