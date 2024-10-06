# AWSプロバイダーの設定（東京リージョン）
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Env     = "haruka-aibara"
      Project = local.app_name
    }
  }
}
