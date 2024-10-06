resource "aws_sns_topic" "this" {
  name = "${local.app_name}_topic"
}
