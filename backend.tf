#
# Terraform 원격 상태 저장용 backend 리소스 (S3 + DynamoDB)
#
# provider.tf 의 backend 블록이 이 리소스들을 사용한다.
# backend 는 init 시점에 이미 존재해야 하므로, 새 환경에서는
# backend 블록을 주석 처리하고 로컬 state 로 이 파일만 먼저 apply 한다.
#
# (파일명이 mian.tf 오타였는데 backend.tf 로 바꿨다. 파일명은 리소스
#  주소에 영향이 없으므로 state 에는 변화가 없다.)
#

resource "aws_s3_bucket" "terraform_state" {
  bucket = "bipa17-std15-terraform-state-bucket"

  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "std15-terraform-state-bucket"
  }
}


resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }

}


resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "bipa17-std15-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "std15-terraform-state-lock"
  }

}


# state 파일에는 비밀번호 등 민감 정보가 들어가므로 기본 암호화를 켠다.
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# state 버킷은 절대 퍼블릭이 되면 안 되므로 모두 차단한다.
resource "aws_s3_bucket_public_access_block" "state_public_access_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
