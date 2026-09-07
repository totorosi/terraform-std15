# for_each는 map 또는 set의 각 항목을 반복해서 리소스를 생성합니다.
# subnet_cidr의 각 항목을 하나의 Subnet으로 생성합니다.

resource "aws_subnet" "each" {
  for_each = {
    for index, subnet in var.subnet_cidr : index => {
      availability_zone = keys(subnet)[0]
      cidr_block        = values(subnet)[0]
    }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = tonumber(each.key) < 3

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-subnet-${tonumber(each.key) + 1}"
    Type = tonumber(each.key) < 3 ? "public" : "private"
  })
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

# for_each로 생성된 인스턴스의 이름과 ID를 출력합니다.
output "instances_each" {
  value = {
    for name, instance in aws_instance.each : name => instance.id
  }
}


#테라폼은 선언형 언어, if문이 없다.
#if문을 대체하는 3항 연산자를 통해 간단한 제어만 가능.

resource "aws_instance" "each" {
  for_each = {
    logs = {
      subnet_key = "0"
      is_public  = true
    }
    media = {
      subnet_key = "1"
      is_public  = true
    }
    backups = {
      subnet_key = "3"
      is_public  = false
    }
  }

  subnet_id     = aws_subnet.each[each.value.subnet_key].id
  ami           = "ami-0aa2bfca464a9be6b"
  instance_type = "t3.micro"

  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${each.key}-instance"
    Type = each.value.is_public ? "public" : "private"
  })
}

locals {
  instance_type = "default"
}

resource "aws_instance" "csjin_ec2" {
  subnet_id = aws_subnet.each["0"].id
  ami       = "ami-0aa2bfca464a9be6b"
  instance_type = local.instance_type == "default" ? "t3.micro" : (
    local.instance_type == "small" ? "t3.small" : (
      local.instance_type == "medium" ? "t3.medium" : (
        local.instance_type == "large" ? "t3.large" : "t3.micro"
      )
    )
  )

  tags = {
    Name = "csjin-instance"
  }
}


output "zfunc_string_upper" {
  value = upper("hello world")
}

output "zfunc_string_lower" {
  value = lower("HELLO WORLD")
}


output "zfunc_string_replace" {
  value = replace("hello world", "world", "terraform")
}


output "zfunc_string_split" {
  value = split(",", "hello,world,terraform")[length(split(",", "hello,world,terraform")) - 1]
}

output "zfunc_string_join" {
  value = join("-", ["hello", "world", "terraform"])
}

output "zfunc_string_trimspace" {
  value = trimspace("   hello world   ")
}

output "zfunc_string_replace_symbol" {
  value = replace("hello-world-terraform", "-", "*")
}

output "for" {
  value = [for num in [185, 18, 156317, 174, 123, 15] : num if num % 2 == 0]
}
