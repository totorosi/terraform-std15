// data 리소스 이름은 두 번째 라벨로 지정합니다.
// data "<TYPE>" "<NAME>" { }

data "aws_vpc" "vpc_id" {
  id = aws_vpc.main.id
}

output "vpc_info" {
  value = {
    id   = data.aws_vpc.vpc_id.id
    cidr = data.aws_vpc.vpc_id.cidr_block
  }
}

data "aws_availability_zones" "available_az" {
  state = "available"

}

output "available_az" {
  value = data.aws_availability_zones.available_az.names
}

