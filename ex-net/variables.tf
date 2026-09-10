#
# 공통
#
variable "region" {
  description = "리소스를 생성할 AWS 리전"
  type        = string
  default     = "sa-east-1"
}

variable "name" {
  description = "리소스 이름에 사용할 프로젝트 접두사"
  type        = string
  default     = "std15-ex-net"
}

variable "tags" {
  description = "모든 리소스에 공통으로 적용할 태그"
  type        = map(string)
  default = {
    Project     = "std15-ex-net"
    Environment = "dev"
  }
}

#
# 네트워크
#
variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "사용할 Availability Zone 목록. 비워 두면 리전의 앞쪽 AZ를 subnet 개수만큼 사용합니다."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "public subnet CIDR 목록"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "private subnet CIDR 목록"
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.public_subnet_cidrs)
    error_message = "private_subnet_cidrs 와 public_subnet_cidrs 의 개수가 같아야 합니다."
  }
}

variable "admin_cidr_blocks" {
  description = "SSH 접속을 허용할 CIDR 목록"
  type        = list(string)
  default     = []
}

#
# EC2 / Auto Scaling
#
variable "instance_count" {
  description = "생성할 EC2 인스턴스 수"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "EC2에 사용할 AMI ID"
  type        = string
  default     = "ami-0aa2bfca464a9be6b"
}

variable "key_name" {
  description = "AWS에 등록된 EC2 Key Pair 이름"
  type        = string
  default     = "std15"
}

variable "asg_min_size" {
  description = "Auto Scaling Group 최소 인스턴스 수"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Auto Scaling Group 최대 인스턴스 수"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Auto Scaling Group 희망 인스턴스 수"
  type        = number
  default     = 2
}

#
# RDS(MySQL)
#
variable "db_name" {
  description = "생성할 MySQL 데이터베이스 이름"
  type        = string
  default     = "std15mysqldb"
}

variable "db_username" {
  description = "MySQL master 사용자 이름"
  type        = string
  default     = "std15"
}

variable "db_port" {
  description = "MySQL 접속 포트"
  type        = number
  default     = 3306
}

#
# Aurora MySQL Cluster (mysql_cluster.tf)
#
variable "db_cluster_instance_class" {
  description = "Aurora 클러스터 인스턴스 타입. Aurora MySQL 8.0 은 db.t3.micro 를 지원하지 않는다."
  type        = string
  default     = "db.t3.medium"
}

variable "db_cluster_instance_count" {
  description = "Aurora 클러스터 인스턴스 수. 1이면 writer 만, 2 이상이면 나머지가 reader 가 된다."
  type        = number
  default     = 1

  validation {
    condition     = var.db_cluster_instance_count >= 1
    error_message = "클러스터에는 writer 인스턴스가 최소 1개 필요합니다."
  }
}

variable "db_rotation_days" {
  description = "Secrets Manager 비밀번호 자동 교체 주기(일)"
  type        = number
  default     = 30
}
