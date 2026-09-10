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
  }

  # backend 블록은 변수를 쓸 수 없으므로 값을 직접 적는다.
  # 이 버킷과 테이블은 backend.tf 에서 선언한다.
  #
  # NOTE: dynamodb_table 은 deprecated 이며 use_lockfile = true 로 교체해야 한다.
  #       다만 현재 이 state 는 S3 객체와 DynamoDB Digest 가 불일치한 상태이므로
  #       state 를 먼저 복구한 뒤에 교체할 것. (README "상태 파일 주의사항" 참고)
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
  region = var.region

  default_tags {
    tags = {
      Class = "bipa17"
      Owner = "std15"
    }
  }
}
