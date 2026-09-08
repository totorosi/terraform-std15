
data "aws_subnets" "std15_subnet_ids" {
  # filter {
  #         name   = "vpc-id"
  #         values = ["vpc-id"]
  # }
  filter {
    name = "tag:Name"
    values = ["std15-private-sa-east-1a-subnet",
      "std15-private-sa-east-1b-subnet",
    "std15-private-sa-east-1c-subnet"]
  }
}



resource "aws_db_subnet_group" "std15_db_subnet_group" {
  name = "std15-db-subnet-group"

  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id,
    aws_subnet.private[2].id
  ]

  tags = {
    Name = "std15-db-subnet-group"
  }
}

output "choice_subnets" {
  value = data.aws_subnets.std15_subnet_ids.ids
}

resource "aws_db_instance" "std15_mysql_instance" {
  identifier        = "std15-mysql-instance"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name           = "std15mysqldb"
  username          = "std15"
  password          = "std15pass"

  db_subnet_group_name = aws_db_subnet_group.std15_db_subnet_group.name
  availability_zone    = local.azs[0]

  vpc_security_group_ids = [
    aws_security_group.instance.id
  ]

  backup_retention_period = 7
  skip_final_snapshot     = true
  tags = {
    Name = "std15-mysql-instance"
  }
}
