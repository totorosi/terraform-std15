resource "aws_instance" "std15_instance" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = <<-EOF
    #!/bin/bash
    if command -v dnf >/dev/null 2>&1; then
      dnf install -y nginx
    elif command -v apt-get >/dev/null 2>&1; then
      apt-get update -y
      DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
    fi
    systemctl enable nginx
    systemctl start nginx
    mkdir -p /usr/share/nginx/html
    echo "<h1>std15-ex-net instance</h1>" > /usr/share/nginx/html/index.html
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
  description = "생성된 EC2 인스턴스의 public IP 목록"
  value       = aws_instance.std15_instance[*].public_ip
}
