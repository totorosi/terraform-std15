resource "aws_instance" "std15_instance" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = var.user_data

  depends_on = [aws_internet_gateway.std15_igw]

  tags = merge(var.tags, {
    Name = "${var.name}-instance-${count.index + 1}"
    Tier = "public"
  })
}
