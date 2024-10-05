# AWSプロバイダーの設定（東京リージョン）
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Env     = "haruka-aibara"
      Project = local.app_name
    }
  }
}
