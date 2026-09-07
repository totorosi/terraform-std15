# variable 예제: 문자열 변수
variable "name" {
  description = "이름"
  type        = string
  default     = "example"
}

output "name" {
  description = "이름 출력"
  value       = var.name
}

# variable은 외부에서 값을 입력받기 위한 Terraform 변수입니다.
# type은 변수에 입력할 수 있는 값의 자료형을 지정합니다.
# default는 별도의 입력값이 없을 때 사용할 기본값입니다.

variable "region" {
  # 문자열(string) 형태의 AWS 리전 값입니다.
  description = "AWS 리전"
  type        = string
  default     = "sa-east-1"
}

output "region" {
  # output은 terraform apply 후 결과로 확인할 값을 정의합니다.
  description = "AWS 리전"
  value       = var.region
}

variable "subnet_cidr" {
  # 문자열 목록을 다시 목록으로 묶은 2차원 list입니다.
  # 바깥쪽 목록은 서브넷 그룹이고, 안쪽 목록은 CIDR 블록 목록입니다.
  description = "서브넷 CIDR 블록"
  type        = list(map(string))
  default = [{
    sa-east-1a = "10.0.1.0/24"
    }, {
    sa-east-1b = "10.0.2.0/24"
    }, {
    sa-east-1c = "10.0.3.0/24"
    }, {
    sa-east-1a = "10.0.11.0/24"
    }, {
    sa-east-1b = "10.0.12.0/24"
    }, {
    sa-east-1c = "10.0.13.0/24"
    }
  ]
}

output "subnet_cidr" {
  description = "첫 번째 서브넷 그룹의 CIDR 블록"
  value       = tolist(var.subnet_cidr)[0]
}

variable "tags" {
  # map은 key와 value의 쌍이며, 이 예제에서는 map 여러 개를 list로 묶었습니다.
  # 모든 map의 값은 문자열(string)이어야 합니다.
  description = "서브넷 이름과 CIDR 목록"
  type        = list(map(string))
  default = [{
    name = "public-subnet"
    cidr = "10.0.1.0/24"
    }, {
    name = "private-subnet"
    cidr = "10.0.2.0/24"
  }]
}

output "tags" {
  # list 안에 들어 있는 여러 map 값을 출력합니다.
  description = "리소스 태그 목록"
  value       = var.tags
}

variable "subnet_tuple" {
  # tuple은 순서와 각 위치의 자료형이 고정됩니다.
  # 첫 번째 값은 이름(string), 두 번째 값은 CIDR(string), 세 번째 값은 번호(number)입니다.
  description = "서브넷 이름, CIDR, 번호를 순서대로 저장하는 tuple"
  type        = tuple([string, string, number])
  default     = ["public-subnet", "10.0.1.0/24", 1]
}

output "subnet_tuple" {
  description = "서브넷 정보 tuple"
  value       = var.subnet_tuple
}

variable "subnet_object" {
  # object는 속성 이름과 각 속성의 자료형이 고정됩니다.
  # Terraform object 속성명에는 하이픈(-)을 사용할 수 없어 밑줄(_)을 사용합니다.
  description = "VPC ID, VPC CIDR, 태그를 저장하는 object"
  type = object({
    vpc_id   = string
    vpc_cidr = string
    tags     = list(map(string))
  })
  default = {
    vpc_id   = "vpc-0123456789abcdef0"
    vpc_cidr = "10.0.0.0/16"
    tags = [{
      name = "main-vpc"
      env  = "dev"
    }]
  }
}

output "subnet_object" {
  # object의 VPC 정보와 tags를 포함한 전체 값을 출력합니다.
  description = "VPC 정보 object"
  value       = var.subnet_object
}

variable "regions_list" {
  # list는 중복을 허용하고 입력 순서를 유지합니다.
  description = "AWS 리전 목록"
  type        = list(string)
  default     = ["sa-east-1", "us-east-1", "us-west-1"]
}

output "regions_list" {
  description = "list 타입의 AWS 리전 목록"
  value       = var.regions_list
}

variable "regions_set" {
  # set은 중복을 허용하지 않으며 순서를 보장하지 않습니다.
  description = "중복 없는 AWS 리전 목록"
  type        = set(string)
  default     = ["sa-east-1", "us-east-1", "us-west-1"]
}

output "regions_set" {
  description = "set 타입의 AWS 리전 목록"
  value       = var.regions_set
}

variable "regions_map" {
  # map은 key와 value의 쌍으로 값을 저장합니다.
  description = "환경별 AWS 리전"
  type        = map(string)
  default = {
    dev  = "sa-east-1"
    prod = "us-east-1"
  }
}

output "regions_map" {
  description = "map 타입의 환경별 AWS 리전"
  value       = var.regions_map
}


