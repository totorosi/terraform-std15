#
# Internet Gateway / NAT Gateway
#

resource "aws_internet_gateway" "std15_igw" {
  vpc_id = aws_vpc.std15_lab_vpc.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.std15_igw]

  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip"
  })
}

resource "aws_nat_gateway" "std15_nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.std15_igw]

  tags = merge(var.tags, {
    Name = "${var.name}-nat-gateway"
  })
}

#
# Route Table
#

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.std15_lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.std15_igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(local.azs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(local.azs)
  vpc_id = aws_vpc.std15_lab_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.std15_nat_gateway.id
  }

  tags = merge(var.tags, {
    Name = "${var.name}-private-${local.azs[count.index]}-rt"
  })
}

resource "aws_route_table_association" "private" {
  count = length(local.azs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
