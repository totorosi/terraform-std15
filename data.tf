// data 리소스 이름은 두 번째 라벨로 지정합니다.
// data "<TYPE>" "<NAME>" { }
// output 은 모두 outputs.tf 로 옮겼습니다.

data "aws_vpc" "vpc_id" {
  id = aws_vpc.main.id
}

data "aws_availability_zones" "available_az" {
  state = "available"
}
