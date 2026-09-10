#
# Subnet
#

# for_each는 map 또는 set의 각 항목을 반복해서 리소스를 생성합니다.
# subnet_cidr의 각 항목을 하나의 Subnet으로 생성합니다.
# 앞의 3개(index 0~2)는 public, 뒤의 3개(index 3~5)는 private입니다.
resource "aws_subnet" "each" {
  for_each = {
    for index, subnet in var.subnet_cidr : index => {
      availability_zone = keys(subnet)[0]
      cidr_block        = values(subnet)[0]
    }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = tonumber(each.key) < 3

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-subnet-${tonumber(each.key) + 1}"
    Type = tonumber(each.key) < 3 ? "public" : "private"
  })
}
