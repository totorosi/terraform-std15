resource "aws_s3_bucket" "std15_s3_bucket" {
  bucket = "std15-s3-bucket"

  force_destroy       = false
  object_lock_enabled = false

  tags = merge(var.tags, {
    Name = "std15-s3-bucket"
  })
}

# 정적 웹사이트 호스팅용 버킷이므로 퍼블릭 차단을 모두 해제한다.
# (주석과 값이 반대로 적혀 있어서 설명을 실제 동작에 맞게 고쳤다.)
resource "aws_s3_bucket_public_access_block" "std15_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.std15_s3_bucket.id

  # 1. 퍼블릭 ACL 추가를 허용한다.
  block_public_acls = false

  # 2. 이미 설정된 퍼블릭 ACL 을 무시하지 않는다.
  ignore_public_acls = false

  # 3. 퍼블릭 버킷 정책 등록을 허용한다. (아래 bucket policy 가 필요로 한다)
  block_public_policy = false

  # 4. 퍼블릭 정책이 걸린 버킷에 대한 익명 접근을 허용한다.
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

# Public 사용자에게 객체 읽기 권한을 부여하는 정책
resource "aws_s3_bucket_policy" "std15_s3_bucket_policy" {
  bucket = aws_s3_bucket.std15_s3_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.std15_s3_bucket_public_access_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.std15_s3_bucket.arn}/*"
      }
    ]
  })
}
