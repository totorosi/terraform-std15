resource "aws_s3_bucket" "terraform_state" {
  bucket = "bipa17-std15-terraform-state-bucket"

  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "sdt15-ex-terraform-state-bucket"
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
    Name = "sdt15-ex-terraform-state-lock"
  }

}
