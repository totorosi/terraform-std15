variable "name" {
  description = "리소스 이름에 사용할 프로젝트 접두사"
  type        = string
  default     = "std15-ex-net"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "사용할 Availability Zone 목록. 비워 두면 리전의 첫 3개 AZ를 사용합니다."
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
}

variable "admin_cidr_blocks" {
  description = "SSH 접속을 허용할 CIDR 목록"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "모든 리소스에 공통으로 적용할 태그"
  type        = map(string)
  default = {
    Project     = "std15-ex-net"
    Environment = "dev"
  }
}
