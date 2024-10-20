resource "aws_sns_topic" "this" {
  name = "${local.project_name}_topic"
}
