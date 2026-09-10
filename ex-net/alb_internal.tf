#
# Internal ALB
#
# internal-alb-sg 만 있고 이를 사용하는 로드밸런서가 없어서 추가했다.
# VPC 내부 클라이언트가 nginx 백엔드에 접근하는 내부 진입점 역할을 한다.
#
resource "aws_lb" "std15_internal_alb" {
  name               = "std15-nginx-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb.id]
  subnets            = aws_subnet.private[*].id

  tags = merge(var.tags, {
    Name = "${var.name}-internal-alb"
    Tier = "private"
  })
}

resource "aws_lb_target_group" "std15_internal_tg" {
  name                 = "std15-nginx-internal-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.std15_lab_vpc.id
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
    Name = "${var.name}-internal-tg"
  })
}

# external ALB 쪽 target group 은 ASG 가 등록하지만,
# 내부 target group 은 단독 EC2 인스턴스를 직접 등록한다.
resource "aws_lb_target_group_attachment" "std15_internal_tg_attachment" {
  count = var.instance_count

  target_group_arn = aws_lb_target_group.std15_internal_tg.arn
  target_id        = aws_instance.std15_instance[count.index].id
  port             = 80
}

resource "aws_lb_listener" "std15_internal_listener" {
  load_balancer_arn = aws_lb.std15_internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.std15_internal_tg.arn
    type             = "forward"
  }
}
