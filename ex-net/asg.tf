resource "aws_launch_template" "std15_lt" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instance.id, aws_security_group.ssh.id]
  user_data              = base64encode(local.user_data)

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

    tags = merge(var.tags, {
      Name = "${var.name}-asg-instance-volume"
    })
  }
}

resource "aws_autoscaling_group" "std15_nginx_asg" {
  name                = "std15-nginx-asg"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = aws_subnet.public[*].id

  # ALB target group 등록이 빠져 있어서 ALB 에 대상이 하나도 없었다.
  target_group_arns         = [aws_lb_target_group.std15_nginx_tg.arn]
  health_check_type         = "ELB"
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

# recurrence 는 "분 시 일 월 요일" 순서다.
# 현재 값은 실습용으로 13:06 확장 / 13:10 축소(4분 간격)로 되어 있다.
resource "aws_autoscaling_schedule" "std15_nginx_scale_up" {
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

# 스케줄 리소스 이름 오타 정리 (std15_nginx_schedule -> std15_nginx_scale_up)
moved {
  from = aws_autoscaling_schedule.std15_nginx_schedule
  to   = aws_autoscaling_schedule.std15_nginx_scale_up
}
