#
# 1. 테라폼 실행 환경설정 블록
#
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # secretsmanager.tf 의 random_password 가 사용한다.
    # lock 파일에는 있었지만 required_providers 에 빠져 있어서 추가했다.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }

  # backend 블록은 변수를 쓸 수 없으므로 리전을 직접 적는다.
  backend "s3" {
    bucket = "bipa17-std15-terraform-state-bucket"
    key    = "ex-net/terraform.tfstate"
    region = "sa-east-1"
    # dynamodb_table 은 deprecated 이므로 S3 네이티브 락으로 교체했다.
    use_lockfile = true
    encrypt      = true
  }
}


#
# 2. AWS 프로바이더 설정 — 리전
#
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Class = "bipa17"
      Owner = "std15"
    }
  }
}
