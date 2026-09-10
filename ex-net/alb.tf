resource "aws_lb" "std15_nginx_alb" {
  name               = "std15-nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_alb.id]
  subnets            = aws_subnet.public[*].id

  tags = merge(var.tags, {
    Name = "std15-nginx-alb"
  })
}

resource "aws_lb_target_group" "std15_nginx_tg" {
  name                 = "std15-nginx-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.std15_lab_vpc.id
  slow_start           = 30
  deregistration_delay = 60

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name = "std15-nginx-tg"
  })
}

# target group 에 붙는 인스턴스는 asg.tf 의
# aws_autoscaling_group.target_group_arns 가 등록한다.

resource "aws_lb_listener" "std15_nginx_listener" {
  load_balancer_arn = aws_lb.std15_nginx_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.std15_nginx_tg.arn
    type             = "forward"
  }
}

# HTTPS 리스너는 ACM 인증서를 먼저 발급한 뒤 활성화한다.
# resource "aws_lb_listener" "std15_nginx_https_listener" {
#   load_balancer_arn = aws_lb.std15_nginx_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
#   certificate_arn   = "<ACM certificate ARN>"
#
#   default_action {
#     target_group_arn = aws_lb_target_group.std15_nginx_tg.arn
#     type             = "forward"
#   }
# }
#
# resource "aws_lb_listener_rule" "std15_lb_path_rule" {
#   listener_arn = aws_lb_listener.std15_nginx_https_listener.arn
#   priority     = 100
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.std15_nginx_tg.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/api", "/api/*"]
#     }
#   }
# }
