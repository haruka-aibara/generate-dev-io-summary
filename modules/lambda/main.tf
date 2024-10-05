resource "aws_lambda_layer_version" "layer" {
  filename                 = var.layer_zip_path
  layer_name               = "${var.function_name}_layer"
  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["x86_64"]
  description              = "Lambda layer for ${var.function_name}"
  source_code_hash         = var.layer_source_code_hash
}

resource "aws_lambda_function" "this" {

  function_name = var.function_name
  role          = var.role

  # architectures = ["x86_64"]

  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  layers           = [aws_lambda_layer_version.layer.arn]
  source_code_hash = filebase64sha256(var.filename)
  filename         = var.filename
  environment {
    variables = var.environment_variables
  }
}
