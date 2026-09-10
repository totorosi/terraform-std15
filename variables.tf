#
# 입력 변수 정의 전용 파일입니다.
# variable 은 외부에서 값을 입력받기 위한 Terraform 변수입니다.
# type 은 변수에 입력할 수 있는 값의 자료형을, default 는 기본값을 지정합니다.
#
# 각 변수를 출력하는 output 예제는 examples.tf 에 있습니다.
#

#
# 실제 리소스가 사용하는 변수
#
variable "region" {
  # 문자열(string) 형태의 AWS 리전 값입니다.
  description = "AWS 리전"
  type        = string
  default     = "sa-east-1"
}

variable "subnet_cidr" {
  # map 을 원소로 갖는 list 입니다. key 는 AZ, value 는 CIDR 블록입니다.
  # 앞의 3개는 public, 뒤의 3개는 private subnet 으로 사용합니다.
  description = "서브넷 AZ와 CIDR 블록 목록"
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

variable "ami_id" {
  description = "EC2에 사용할 AMI ID"
  type        = string
  default     = "ami-0aa2bfca464a9be6b"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

#
# 자료형 학습용 변수 (리소스에서 사용하지 않습니다)
#
variable "name" {
  description = "이름"
  type        = string
  default     = "example"
}

variable "tags" {
  # map 은 key 와 value 의 쌍이며, 이 예제에서는 map 여러 개를 list 로 묶었습니다.
  # 모든 map 의 값은 문자열(string)이어야 합니다.
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

variable "subnet_tuple" {
  # tuple 은 순서와 각 위치의 자료형이 고정됩니다.
  # 첫 번째 값은 이름(string), 두 번째 값은 CIDR(string), 세 번째 값은 번호(number)입니다.
  description = "서브넷 이름, CIDR, 번호를 순서대로 저장하는 tuple"
  type        = tuple([string, string, number])
  default     = ["public-subnet", "10.0.1.0/24", 1]
}

variable "subnet_object" {
  # object 는 속성 이름과 각 속성의 자료형이 고정됩니다.
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

variable "regions_list" {
  # list 는 중복을 허용하고 입력 순서를 유지합니다.
  description = "AWS 리전 목록"
  type        = list(string)
  default     = ["sa-east-1", "us-east-1", "us-west-1"]
}

variable "regions_set" {
  # set 은 중복을 허용하지 않으며 순서를 보장하지 않습니다.
  description = "중복 없는 AWS 리전 목록"
  type        = set(string)
  default     = ["sa-east-1", "us-east-1", "us-west-1"]
}

variable "regions_map" {
  # map 은 key 와 value 의 쌍으로 값을 저장합니다.
  description = "환경별 AWS 리전"
  type        = map(string)
  default = {
    dev  = "sa-east-1"
    prod = "us-east-1"
  }
}
