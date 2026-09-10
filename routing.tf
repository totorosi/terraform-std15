#
# Internet Gateway / NAT Gateway / Route Table
#

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

# private route table 에는 0.0.0.0/0 경로가 없다.
# 외부로 나가야 하면 NAT Gateway 를 추가해야 한다. (ex-net/network.tf 참고)

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
