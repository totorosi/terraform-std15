#
# 1. 테라폼 실행 환경설정 블록
#
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "bipa17-std15-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "bipa17-std15-terraform-state-lock"
    encrypt        = true
  }
}


#
# 2. AWS 프로바이더 설정 — 리전
#
provider "aws" {
  region = "sa-east-1"
  default_tags {
    tags = {
      Class = "bipa17"
      Owner = "std15"
    }
  }
}
