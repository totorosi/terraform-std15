resource "aws_instance" "std15_instance" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  vpc_security_group_ids      = [aws_security_group.instance.id, aws_security_group.ssh.id]
  user_data                   = local.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  depends_on = [aws_internet_gateway.std15_igw]

  tags = merge(var.tags, {
    Name = "${var.name}-instance-${count.index + 1}"
    Tier = "public"
  })
}

# 리소스 이름 오타(st15 -> std15)를 고치면서 기존 state 를 그대로 이어받는다.
# apply 후에는 이 moved 블록을 삭제해도 된다.
moved {
  from = aws_instance.st15_ami_instance
  to   = aws_instance.std15_ami_instance
}

# AMI 를 굽기 위한 베이스 인스턴스
resource "aws_instance" "std15_ami_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instance.id, aws_security_group.ssh.id]
  # 기존 스크립트는 nginx 설치 없이 systemctl start 만 했기 때문에 실패했다.
  user_data = local.user_data

  volume_tags = merge(var.tags, {
    Name = "${var.name}-ami-instance-volume"
  })

  tags = merge(var.tags, {
    Name = "${var.name}-ami-instance"
    Tier = "public"
  })
}
