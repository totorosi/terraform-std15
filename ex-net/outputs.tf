#
# 모든 output 은 이 파일에 모아 둔다.
#

#
# 네트워크
#
output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.std15_lab_vpc.id
}

output "availability_zones" {
  description = "실제로 사용한 Availability Zone 목록"
  value       = local.azs
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
    mysql        = aws_security_group.mysql.id
  }
}

#
# EC2 / Auto Scaling
#
output "instance_ids" {
  description = "생성된 EC2 인스턴스 ID 목록"
  value       = aws_instance.std15_instance[*].id
}

output "instance_public_ips" {
  description = "생성된 EC2 인스턴스 public IP 목록"
  value       = aws_instance.std15_instance[*].public_ip
}

output "ami_instance_public_ip" {
  description = "AMI 베이스 인스턴스의 public IP"
  value       = aws_instance.std15_ami_instance.public_ip
}

output "asg_name" {
  description = "Auto Scaling Group 이름"
  value       = aws_autoscaling_group.std15_nginx_asg.name
}

#
# ALB
#
output "alb_dns_name" {
  description = "ALB DNS 이름"
  value       = aws_lb.std15_nginx_alb.dns_name
}

output "alb_url" {
  description = "브라우저로 접속할 ALB 주소"
  value       = "http://${aws_lb.std15_nginx_alb.dns_name}"
}

output "internal_alb_dns_name" {
  description = "Internal ALB DNS 이름 (VPC 내부에서만 조회 가능)"
  value       = aws_lb.std15_internal_alb.dns_name
}

#
# RDS(MySQL)
#
output "db_subnet_group_name" {
  description = "RDS DB Subnet Group 이름"
  value       = aws_db_subnet_group.std15_db_subnet_group.name
}

output "mysql_endpoint" {
  description = "MySQL 접속 엔드포인트 (host:port)"
  value       = aws_db_instance.std15_mysql_instance.endpoint
}

output "mysql_secret_arn" {
  description = "MySQL 접속 정보가 담긴 Secrets Manager Secret ARN"
  value       = aws_secretsmanager_secret.mysql_password.arn
}

output "mysql_password" {
  description = "MySQL master 비밀번호"
  value       = random_password.mysql_password.result
  sensitive   = true
}

#
# Aurora MySQL Cluster
#
output "mysql_cluster_endpoint" {
  description = "Aurora 클러스터 writer 엔드포인트"
  value       = aws_rds_cluster.std15_mysql_cluster.endpoint
}

output "mysql_cluster_reader_endpoint" {
  description = "Aurora 클러스터 reader 엔드포인트 (인스턴스가 2개 이상일 때 의미가 있다)"
  value       = aws_rds_cluster.std15_mysql_cluster.reader_endpoint
}

output "mysql_cluster_engine_version" {
  description = "실제로 선택된 Aurora 엔진 버전"
  value       = aws_rds_cluster.std15_mysql_cluster.engine_version_actual
}

output "mysql_cluster_secret_arn" {
  description = "Aurora 클러스터 접속 정보가 담긴 Secrets Manager Secret ARN"
  value       = aws_secretsmanager_secret.mysql_cluster.arn
}

output "mysql_rotation_lambda_arn" {
  description = "비밀번호 자동 교체를 수행하는 Lambda ARN"
  value       = aws_serverlessapplicationrepository_cloudformation_stack.mysql_rotation.outputs.RotationLambdaARN
}

#
# S3
#
output "s3_bucket_name" {
  description = "생성된 S3 버킷 이름"
  value       = aws_s3_bucket.std15_s3_bucket.id
}

output "s3_website_endpoint" {
  description = "S3 정적 웹사이트 엔드포인트"
  value       = aws_s3_bucket_website_configuration.std15_s3_bucket_website_configuration.website_endpoint
}
