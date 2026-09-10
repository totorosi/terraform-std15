#
# Aurora MySQL Cluster + Secrets Manager 자동 교체(rotation)
#
# mysql.tf 의 단독 aws_db_instance 와는 별개의 리소스다.
# 둘 다 apply 하면 요금이 두 배로 나가니, 실습이 끝나면 한쪽은 지우자.
#
#
# RDS Proxy 용 IAM 역할
#
# 주의: 이 역할을 사용하는 aws_db_proxy 리소스가 아직 없다.
#       IAM 역할/정책 자체는 요금이 없으니 그대로 둬도 되지만,
#       실제로 Proxy 를 쓰려면 aws_db_proxy + aws_db_proxy_default_target_group
#       + aws_db_proxy_target 을 추가해야 한다.
#
resource "aws_iam_role" "proxy_role" {
  name = "${local.tag_header}rds-proxy-secrets-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "${local.tag_header}rds-proxy-secrets-role"
  }
}

resource "aws_iam_role_policy" "proxy_policy" {
  name = "${local.tag_header}rds-proxy-secrets-policy"
  role = aws_iam_role.proxy_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.mysql_cluster.arn
      },
    ]
  })
}


# 클러스터와 rotation Lambda 가 함께 사용하는 SG.
# Lambda 도 같은 SG 를 쓰기 때문에 self 규칙으로 3306 을 열어 준다.
resource "aws_security_group" "std15_mysql_sg" {
  name        = "${var.name}-mysql-cluster-sg"
  description = "Aurora MySQL cluster and rotation Lambda access"
  vpc_id      = aws_vpc.std15_lab_vpc.id

  # rotation Lambda -> cluster (같은 SG 안에서의 통신)
  ingress {
    description = "MySQL from the rotation Lambda in the same SG"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    self        = true
  }

  # EC2 -> cluster
  ingress {
    description     = "MySQL from the EC2 instances"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.instance.id]
  }

  # Lambda 가 NAT Gateway 를 거쳐 Secrets Manager 엔드포인트에 접근해야 한다.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-mysql-cluster-sg"
  })
}


#
# 1. 보안암호 생성
#
# rotation Lambda 는 secret 의 JSON 키 이름이 정해져 있다.
# engine / host / username / password / dbname / port 를 그대로 써야 동작한다.
#
# 보안암호 삭제는 recovery window 때문에 즉시 되지 않는다.
# 아래 리소스는 recovery_window_in_days = 0 이라 destroy 시 바로 지워지지만,
# 콘솔에서 만든 secret 은 다음 명령으로 강제 삭제한다.
#
# aws secretsmanager delete-secret \
#   --secret-id "project/mysql/password" \
#   --force-delete-without-recovery
#
resource "random_password" "mysql_cluster_password" {
  length  = 16
  special = true

  # RDS MySQL master password 는 '/', '@', '"', 공백을 쓸 수 없다.
  override_special = "!#$%^&*()_+-=[]{}|;:,.<>?"
}

resource "aws_secretsmanager_secret" "mysql_cluster" {
  name        = "${var.name}/mysql-cluster"
  description = "Aurora MySQL cluster master credentials for ${var.name}"

  # 실습용이라 destroy 후 같은 이름으로 바로 재생성할 수 있게 복구 대기를 없앤다.
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "${var.name}-mysql-cluster-secret"
  })
}

resource "aws_secretsmanager_secret_version" "mysql_cluster" {
  secret_id = aws_secretsmanager_secret.mysql_cluster.id

  secret_string = jsonencode({
    engine   = "mysql"
    host     = aws_rds_cluster.std15_mysql_cluster.endpoint
    username = var.db_username
    password = random_password.mysql_cluster_password.result
    dbname   = var.db_name
    port     = var.db_port
  })

  # rotation 이 시작되면 Lambda 가 새 버전을 만든다.
  # 그 뒤로는 Terraform 이 비밀번호를 되돌리지 않도록 무시한다.
  lifecycle {
    ignore_changes = [secret_string]
  }
}


#
# 2. RDS Secrets Manager Automatic Rotation 설정
#
# 교체 작업을 수행할 Lambda 는 AWS 가 Serverless Application Repository 에
# 공개한 템플릿(SecretsManagerRDSMySQLRotationSingleUser)을 그대로 배포한다.
# 이 템플릿이 Lambda, 실행 역할, Secrets Manager 호출 권한까지 함께 만든다.
#
# 참고: aws_rds_cluster 에 manage_master_user_password = true 를 주면
#       Lambda 없이 AWS 관리형 교체를 쓸 수 있다. 여기서는 동작 원리를 보려고
#       Lambda 방식을 쓴다.
#
resource "aws_serverlessapplicationrepository_cloudformation_stack" "mysql_rotation" {
  name           = "${var.name}-mysql-rotation-stack"
  application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSMySQLRotationSingleUser"

  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_RESOURCE_POLICY",
    "CAPABILITY_AUTO_EXPAND",
  ]

  parameters = {
    functionName = "${var.name}-mysql-rotation"

    # Lambda 가 호출할 Secrets Manager 엔드포인트
    endpoint = "https://secretsmanager.${var.region}.amazonaws.com"

    # Lambda 를 VPC 안에 붙여야 cluster 에 접속할 수 있다.
    vpcSubnetIds        = join(",", aws_subnet.private[*].id)
    vpcSecurityGroupIds = aws_security_group.std15_mysql_sg.id

    # 생성되는 비밀번호에서 제외할 문자 (random_password 와 동일 기준)
    excludeCharacters = "/@\"'\\"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-mysql-rotation"
  })

  lifecycle {
    ignore_changes = [parameters, semantic_version, tags]
  }
}

resource "aws_secretsmanager_secret_rotation" "mysql_cluster" {
  secret_id           = aws_secretsmanager_secret.mysql_cluster.id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.mysql_rotation.outputs.RotationLambdaARN

  rotation_rules {
    automatically_after_days = var.db_rotation_days
  }

  # 최초 값이 들어 있어야 Lambda 가 교체를 시작할 수 있다.
  depends_on = [aws_secretsmanager_secret_version.mysql_cluster]
}


#
# 3. RDS Cluster 구성
#
# 볼륨 Type (gp3/io1)
#  - gp3 는 400GB 이하일 때 iops 를 지정하지 않는다.
#  - 콘솔에서 볼륨 설정을 바꿔도 Terraform 이 되돌리지 않도록
#    lifecycle.ignore_changes 로 막아 둔다.
#
resource "aws_rds_cluster" "std15_mysql_cluster" {
  cluster_identifier = "std15-mysql-cluster"
  engine             = "aurora-mysql"
  engine_version     = data.aws_rds_engine_version.aurora_mysql.version_actual

  database_name   = var.db_name
  master_username = var.db_username
  master_password = random_password.mysql_cluster_password.result
  port            = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.std15_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.std15_mysql_sg.id]

  storage_encrypted       = true
  backup_retention_period = 7
  skip_final_snapshot     = true

  # rotation Lambda 가 비밀번호를 바꾸므로 이후 변경을 Terraform 이 되돌리지 않게 한다.
  lifecycle {
    ignore_changes = [master_password, storage_type, allocated_storage, iops]
  }

  tags = merge(var.tags, {
    Name = "std15-mysql-cluster"
  })
}

# 인스턴스를 2개 이상으로 늘리면 나머지가 읽기 전용 replica 가 된다.
# (요금이 인스턴스 수만큼 늘어난다)
resource "aws_rds_cluster_instance" "std15_mysql_cluster_instance" {
  count = var.db_cluster_instance_count

  identifier          = "std15-mysql-cluster-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.std15_mysql_cluster.id
  engine              = aws_rds_cluster.std15_mysql_cluster.engine
  engine_version      = aws_rds_cluster.std15_mysql_cluster.engine_version
  instance_class      = var.db_cluster_instance_class
  publicly_accessible = false

  tags = merge(var.tags, {
    Name = "std15-mysql-cluster-${count.index + 1}"
  })
}
