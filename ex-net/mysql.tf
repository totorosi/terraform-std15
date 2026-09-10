# 기존 data "aws_subnets" "std15_subnet_ids" 는 삭제했다.
#  - vpc-id 필터가 없어서 계정 전체를 검색했고
#  - tag:Name 값("std15-private-sa-east-1a-subnet")이 실제로 생성되는
#    태그("std15-ex-net-private-sa-east-1a")와 달라 항상 빈 결과였다.
#  - 같은 모듈에서 만든 subnet 은 aws_subnet.private[*].id 로 바로 참조하면 된다.

resource "aws_db_subnet_group" "std15_db_subnet_group" {
  name       = "std15-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(var.tags, {
    Name = "std15-db-subnet-group"
  })
}

resource "aws_db_instance" "std15_mysql_instance" {
  identifier        = "std15-mysql-instance"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name = var.db_name
  port    = var.db_port

  # 비밀번호를 하드코딩하지 않고 random_password 결과를 사용한다.
  # 실제 값은 secretsmanager.tf 의 Secret 에 저장된다.
  username = var.db_username
  password = random_password.mysql_password.result

  db_subnet_group_name = aws_db_subnet_group.std15_db_subnet_group.name
  availability_zone    = local.azs[0]
  publicly_accessible  = false

  # instance-sg 는 22/80 만 열려 있어 3306 접속이 되지 않았다.
  vpc_security_group_ids = [aws_security_group.mysql.id]

  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = merge(var.tags, {
    Name = "std15-mysql-instance"
  })
}
