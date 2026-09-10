#
# 실제 생성한 리소스의 output 을 모아 둔 파일입니다.
# 자료형/함수 학습용 output 은 examples.tf 에 있습니다.
#

output "vpc_info" {
  description = "생성한 VPC 의 ID 와 CIDR"
  value = {
    id   = data.aws_vpc.vpc_id.id
    cidr = data.aws_vpc.vpc_id.cidr_block
  }
}

output "available_az" {
  description = "현재 리전에서 사용 가능한 Availability Zone 목록"
  value       = data.aws_availability_zones.available_az.names
}

output "subnets_each" {
  description = "for_each로 생성한 Subnet 정보"
  value = {
    for key, subnet in aws_subnet.each : key => {
      id                = subnet.id
      availability_zone = subnet.availability_zone
      cidr_block        = subnet.cidr_block
    }
  }
}

output "route_table_ids" {
  description = "public / private route table ID"
  value = {
    public  = aws_route_table.public.id
    private = aws_route_table.private.id
  }
}

output "instances_each" {
  description = "for_each로 생성한 EC2 인스턴스의 이름과 ID"
  value = {
    for name, instance in aws_instance.each : name => instance.id
  }
}

output "csjin_instance_id" {
  description = "3항 연산자 예제로 생성한 EC2 인스턴스 ID"
  value       = aws_instance.csjin_ec2.id
}

output "state_backend" {
  description = "원격 상태 저장에 사용하는 S3 버킷과 DynamoDB 테이블"
  value = {
    bucket     = aws_s3_bucket.terraform_state.id
    lock_table = aws_dynamodb_table.terraform_state_lock.name
  }
}
