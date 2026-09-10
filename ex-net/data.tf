data "aws_availability_zones" "available_az" {
  state = "available"
}

# Aurora 엔진 버전은 리전마다 제공 목록이 달라서 하드코딩하지 않고 조회한다.
# mysql_cluster.tf 의 aws_rds_cluster 가 사용한다.
data "aws_rds_engine_version" "aurora_mysql" {
  engine  = "aurora-mysql"
  version = "8.0"
  latest  = true
}
