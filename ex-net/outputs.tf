output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.std15_lab_vpc.id
}

output "public_subnet_ids" {
  description = "public subnet ID 목록"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "private subnet ID 목록"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.std15_nat_gateway.id
}

output "security_group_ids" {
  description = "생성된 Security Group ID"
  value = {
    ssh          = aws_security_group.ssh.id
    external_alb = aws_security_group.external_alb.id
    internal_alb = aws_security_group.internal_alb.id
    instance     = aws_security_group.instance.id
  }
}

output "instance_ids" {
  description = "생성된 EC2 인스턴스 ID 목록"
  value       = aws_instance.std15_instance[*].id
}

output "instance_public_ips" {
  description = "생성된 EC2 인스턴스 public IP 목록"
  value       = aws_instance.std15_instance[*].public_ip
}
