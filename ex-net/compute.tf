resource "aws_instance" "std15_instance" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  vpc_security_group_ids = [aws_security_group.instance.id, aws_security_group.ssh.id, aws_security_group.external_alb.id, aws_security_group.internal_alb.id]
  user_data              = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx:3.13.3-alpine
    systemctl enable nginx
    systemctl start nginx
    echo"<h1>std15-ex-net instance</h1>" > /usr/www/html/index.html
    EOF
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

output "instance_public_id" {
  value = aws_instance.std15_instance[*].public_ip
}
