#
# 학습용 예제 output 모음입니다. 실제 리소스와는 무관합니다.
# 실제 리소스의 output 은 outputs.tf 를 보세요.
#

#
# 1. 자료형별 변수 값 확인
#
output "ex_name" {
  description = "string 타입 변수"
  value       = var.name
}

output "ex_region" {
  description = "string 타입 변수 (AWS 리전)"
  value       = var.region
}

output "ex_subnet_cidr_first" {
  description = "list(map(string)) 의 첫 번째 원소"
  value       = tolist(var.subnet_cidr)[0]
}

output "ex_tags" {
  description = "list 안에 들어 있는 여러 map 값"
  value       = var.tags
}

output "ex_subnet_tuple" {
  description = "tuple 타입 변수"
  value       = var.subnet_tuple
}

output "ex_subnet_object" {
  description = "object 타입 변수"
  value       = var.subnet_object
}

output "ex_regions_list" {
  description = "list 타입 변수 (중복 허용, 순서 유지)"
  value       = var.regions_list
}

output "ex_regions_set" {
  description = "set 타입 변수 (중복 불가, 순서 미보장)"
  value       = var.regions_set
}

output "ex_regions_map" {
  description = "map 타입 변수"
  value       = var.regions_map
}

#
# 2. 문자열 함수
#
output "ex_func_upper" {
  value = upper("hello world")
}

output "ex_func_lower" {
  value = lower("HELLO WORLD")
}

output "ex_func_replace" {
  value = replace("hello world", "world", "terraform")
}

output "ex_func_replace_symbol" {
  value = replace("hello-world-terraform", "-", "*")
}

output "ex_func_split_last" {
  description = "split 결과의 마지막 원소"
  value       = element(split(",", "hello,world,terraform"), -1)
}

output "ex_func_join" {
  value = join("-", ["hello", "world", "terraform"])
}

output "ex_func_trimspace" {
  value = trimspace("   hello world   ")
}

#
# 3. for 식 (짝수만 필터링)
#
output "ex_for_even_numbers" {
  value = [for num in [185, 18, 156317, 174, 123, 15] : num if num % 2 == 0]
}
