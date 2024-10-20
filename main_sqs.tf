resource "aws_sqs_queue" "this" {
  name = "${local.project_name}_queue"
}
