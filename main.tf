# Terraform은 현재 폴더의 모든 .tf 파일을 하나의 구성으로 읽습니다.
#
# 파일별 역할:
# - provider.tf: Terraform과 AWS provider 설정
# - variables.tf: 입력 변수와 output
# - local.tf: 여러 리소스에서 재사용하는 local 값
# - data.tf: AWS 데이터 조회
# - network.tf: public/private subnet 생성
# - routing.tf: Internet Gateway와 route table 설정
# - test.tf: 테스트용 EC2 인스턴스
#
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each       = { for key, subnet in aws_subnet.each : key => subnet if tonumber(key) < 3 }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  for_each       = { for key, subnet in aws_subnet.each : key => subnet if tonumber(key) >= 3 }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
