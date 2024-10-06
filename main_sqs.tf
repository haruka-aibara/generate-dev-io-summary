resource "aws_sqs_queue" "this" {
  name = "${local.app_name}_queue"
}
