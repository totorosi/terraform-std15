#
# EC2
#
# 테라폼은 선언형 언어라 if문이 없다.
# 3항 연산자로 간단한 제어만 가능하다.
#
resource "aws_instance" "each" {
  for_each = {
    logs = {
      subnet_key = "0"
      is_public  = true
    }
    media = {
      subnet_key = "1"
      is_public  = true
    }
    backups = {
      subnet_key = "3"
      is_public  = false
    }
  }

  subnet_id     = aws_subnet.each[each.value.subnet_key].id
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${each.key}-instance"
    Type = each.value.is_public ? "public" : "private"
  })
}

# local.instance_type 값에 따라 인스턴스 타입을 고르는 중첩 3항 연산자 예제.
resource "aws_instance" "csjin_ec2" {
  subnet_id     = aws_subnet.each["0"].id
  ami           = var.ami_id
  instance_type = local.instance_type_map[local.instance_type]

  tags = merge(local.common_tags, {
    Name = "csjin-instance"
  })
}
