locals {
  # 여러 리소스에서 재사용할 값을 정의합니다.
  project_name = "std15-terra"

  common_tags = {
    Project     = local.project_name
    Environment = "dev"
  }

  # compute.tf 의 aws_instance.csjin_ec2 가 사용합니다.
  # 중첩 3항 연산자보다 map + lookup 이 읽기 쉽습니다.
  instance_type = "default"

  instance_type_map = {
    default = "t3.micro"
    small   = "t3.small"
    medium  = "t3.medium"
    large   = "t3.large"
  }
}
