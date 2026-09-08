resource "aws_s3_bucket" "std15_s3_bucket" {
  bucket = "std15-s3-bucket"


  force_destroy = false

  object_lock_enabled = false

  tags = {
    Name = "std15-s3-bucket"
  }

}
resource "aws_s3_bucket_public_access_block" "std15_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.std15_s3_bucket.id
  # 1. 새로운 퍼블릭 ACL(권한 리스트) 추가를 막습니다. 누구나 들어오는 권한 추가 Lock
  block_public_acls = false

  # 2. 기존에 설정된 모든 퍼블릭 ACL을 무시합니다. 이미 부여된 외부 노출 권한이 있다면 취소
  ignore_public_acls = false

  # 3. 버킷 정책(Bucket Policy)을 통해 외부인이 접근하는 것을 차단합니다.
  block_public_policy = false

  # 4. 퍼블릭 정책이 걸려있는 버킷에 대한 익명 접근을 엄격히 제한합니다.
  restrict_public_buckets = false
}


resource "aws_s3_bucket_website_configuration" "std15_s3_bucket_website_configuration" {
  bucket = aws_s3_bucket.std15_s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}


# Public 사용자에게 객체 액세스 권한을 부여하는 정책
resource "aws_s3_bucket_policy" "std15_s3_bucket_policy" {
  bucket = aws_s3_bucket.std15_s3_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.std15_s3_bucket_public_access_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.std15_s3_bucket.arn}/*"
      }
    ]
  })
}
