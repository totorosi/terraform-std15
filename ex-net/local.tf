locals {
  # 리소스 이름 접두사. var.name 과 같은 값이며, 실습 노트에서 쓰던
  # "${local.tag_header}xxx" 표기를 그대로 붙여 넣을 수 있게 남겨 둔다.
  tag_header = "${var.name}-"

  # var.availability_zones 를 비워 두면 리전의 앞쪽 AZ를 subnet 개수만큼 사용한다.
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(
    data.aws_availability_zones.available_az.names, 0, length(var.public_subnet_cidrs)
  )

  # aws_instance 와 aws_launch_template 이 같은 부트스트랩 스크립트를 공유한다.
  user_data = templatefile("${path.module}/user_data.sh", {
    name = var.name
  })
}
