#
# Security Group
#
# 하나의 Security Group 안에서 inline 규칙(ingress/egress)과
# aws_security_group_rule 을 섞으면 서로 상태를 덮어쓰므로,
# 이 파일에서는 inline 규칙만 사용한다.
#
resource "aws_security_group" "ssh" {
  name        = "${var.name}-ssh-sg"
  description = "SSH access for administration"
  vpc_id      = aws_vpc.std15_lab_vpc.id

  dynamic "ingress" {
    for_each = length(var.admin_cidr_blocks) > 0 ? [true] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.admin_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-ssh-sg"
  })
}

resource "aws_security_group" "external_alb" {
  name        = "${var.name}-external-alb-sg"
  description = "Public HTTP and HTTPS access"
  vpc_id      = aws_vpc.std15_lab_vpc.id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-external-alb-sg"
  })
}

resource "aws_security_group" "internal_alb" {
  name        = "${var.name}-internal-alb-sg"
  description = "Private HTTP access from the external ALB"
  vpc_id      = aws_vpc.std15_lab_vpc.id

  # 기존 aws_security_group_rule.internal_alb_http 을 inline 으로 옮겼다.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.external_alb.id]
  }

  # VPC 내부 클라이언트(EC2)가 internal ALB 를 호출할 수 있도록 추가했다.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.instance.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-internal-alb-sg"
  })
}

resource "aws_security_group" "instance" {
  name        = "${var.name}-instance-sg"
  description = "HTTP and optional SSH access for EC2 instances"
  vpc_id      = aws_vpc.std15_lab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = length(var.admin_cidr_blocks) > 0 ? [true] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.admin_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-instance-sg"
  })
}

# RDS 전용 Security Group.
# 기존에는 MySQL 이 instance-sg(22/80만 허용)를 쓰고 있어서 3306 이 막혀 있었다.
resource "aws_security_group" "mysql" {
  name        = "${var.name}-mysql-sg"
  description = "MySQL access from the EC2 instances"
  vpc_id      = aws_vpc.std15_lab_vpc.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.instance.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-mysql-sg"
  })
}

#
# Network ACL (public subnet)
#
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.std15_lab_vpc.id

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # ephemeral port (응답 트래픽용)
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  dynamic "ingress" {
    for_each = var.admin_cidr_blocks
    content {
      rule_no    = 130 + tonumber(ingress.key)
      protocol   = "tcp"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 22
      to_port    = 22
    }
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    Name = "${var.name}-public-nacl"
  })
}

resource "aws_network_acl_association" "public" {
  count = length(local.azs)

  subnet_id      = aws_subnet.public[count.index].id
  network_acl_id = aws_network_acl.public.id
}
