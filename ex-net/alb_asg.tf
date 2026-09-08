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

}

# resource "aws_lb_target_group_attachment" "std15_nginx_tg_attachment" {
#   target_group_arn = aws_lb_target_group.std15_nginx_tg.arn
#   target_id        = aws_instance.nginx.id
#   port             = 80
# }

resource "aws_lb_listener" "std15_nginx_listener" {
  load_balancer_arn = aws_lb.std15_nginx_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.std15_nginx_tg.arn
    type             = "forward"
  }
  # default_action {
  #   type = "fixed-response"
  #   fixed_response {
  #     content_type = "text/plain"
  #     status_code  = "200"
  #     message_body = <<-EOF
  #       Hello, World!
  #     EOF
  #   }
  # }
}


# resource "aws_lb_listener" "std15_nginx_https_listener" {
#   load_balancer_arn = aws_lb.std15_nginx_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#
#   ssl_policy = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
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
#       values = ["/api", "api/*"]
#     }
#   }
# }

output "alb_dns" {
  value = aws_lb.std15_nginx_alb
}





resource "aws_lb" "std15_nginx_alb" {
  name               = "std15-nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_alb.id]
  subnets            = [aws_subnet.public[0].id, aws_subnet.public[1].id, aws_subnet.public[2].id]
  tags               = { Name = "std15-nginx-alb" }
}

resource "aws_launch_template" "std15_lt" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instance.id, aws_security_group.ssh.id]
  user_data              = base64encode(var.user_data)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.name}-asg-instance"
      Tier = "public"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = var.tags
  }
}


resource "aws_autoscaling_group" "std15_nginx_asg" {
  name                      = "std15-nginx-asg"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.public[0].id, aws_subnet.public[1].id, aws_subnet.public[2].id]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.std15_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "public"
    propagate_at_launch = true
  }

}


resource "aws_autoscaling_schedule" "std15_nginx_schedule" {
  scheduled_action_name  = "std15-nginx-scale-up"
  autoscaling_group_name = aws_autoscaling_group.std15_nginx_asg.name


  min_size         = 2
  max_size         = 5
  desired_capacity = 4

  recurrence = "06 13 * * 1-5"
  time_zone  = "Asia/Seoul"
}


resource "aws_autoscaling_schedule" "std15_nginx_scale_down" {
  scheduled_action_name  = "std15-nginx-scale-down"
  autoscaling_group_name = aws_autoscaling_group.std15_nginx_asg.name


  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  recurrence = "10 13 * * 1-5"
  time_zone  = "Asia/Seoul"
}
