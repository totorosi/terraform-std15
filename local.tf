locals {
  # 여러 리소스에서 재사용할 값을 정의합니다.
  project_name = "std15-terra"

  common_tags = {
    Project     = local.project_name
    Environment = "dev"
  }
}
