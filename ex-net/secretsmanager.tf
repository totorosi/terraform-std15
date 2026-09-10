# 랜덤한 DB 비밀번호 생성
resource "random_password" "mysql_password" {
  length  = 16
  special = true

  # RDS MySQL master password 는 '/', '@', '"', 공백을 쓸 수 없으므로 제외한다.
  override_special = "!#$%^&*()_+-=[]{}|;:,.<>?"
}

resource "aws_secretsmanager_secret" "mysql_password" {
  name        = "${var.name}/mysql"
  description = "MySQL master credentials for ${var.name}"

  # 실습 환경이라 destroy 후 같은 이름으로 바로 재생성할 수 있게 복구 대기를 없앤다.
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "${var.name}-mysql-secret"
  })
}

resource "aws_secretsmanager_secret_version" "mysql_password_value" {
  secret_id = aws_secretsmanager_secret.mysql_password.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.mysql_password.result
    db_name  = var.db_name
    host     = aws_db_instance.std15_mysql_instance.address
    port     = var.db_port
  })
}
