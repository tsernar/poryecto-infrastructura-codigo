data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-sg-${var.environment}"
  description = "ALB inbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name        = "app-sg-${var.environment}"
  description = "App inbound from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "this" {
  name               = "alb-${var.app_name}-${var.environment}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "blue" {
  name     = "tg-${var.app_name}-${var.environment}-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "green" {
  name     = "tg-${var.app_name}-${var.environment}-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

# Listener con forward ponderado (permite 100/0 o 90/10, etc.)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = var.traffic_weight_blue
      }
      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = var.traffic_weight_green
      }
    }
  }
}

# Launch Template (mismo template, user_data cambia texto para saber si es blue o green)
locals {
  user_data_common = <<-EOT
    #!/bin/bash
    dnf -y update
    dnf -y install nginx
    systemctl enable nginx
    cat > /usr/share/nginx/html/health << 'EOF'
    ok
    EOF
    systemctl start nginx
  EOT
}

resource "aws_launch_template" "blue" {
  name_prefix   = "lt-${var.app_name}-${var.environment}-blue-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(join("\n", [
    local.user_data_common,
    "echo '<h1>${var.app_name} ${var.environment} - BLUE</h1>' > /usr/share/nginx/html/index.html"
  ]))
}

resource "aws_launch_template" "green" {
  name_prefix   = "lt-${var.app_name}-${var.environment}-green-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(join("\n", [
    local.user_data_common,
    "echo '<h1>${var.app_name} ${var.environment} - GREEN</h1>' > /usr/share/nginx/html/index.html"
  ]))
}

# ASG BLUE
resource "aws_autoscaling_group" "blue" {
  name                = "asg-${var.app_name}-${var.environment}-blue"
  vpc_zone_identifier = var.private_subnet_ids

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity_blue

  target_group_arns = [aws_lb_target_group.blue.arn]

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "app-${var.environment}-blue"
    propagate_at_launch = true
  }
}

# ASG GREEN
resource "aws_autoscaling_group" "green" {
  name                = "asg-${var.app_name}-${var.environment}-green"
  vpc_zone_identifier = var.private_subnet_ids

  min_size         = 0
  max_size         = var.max_size
  desired_capacity = var.desired_capacity_green

  target_group_arns = [aws_lb_target_group.green.arn]

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "app-${var.environment}-green"
    propagate_at_launch = true
  }
}

# Auto-scaling policy (target tracking CPU 50%) para ambos
resource "aws_autoscaling_policy" "blue_cpu" {
  name                   = "cpu-${var.environment}-blue"
  autoscaling_group_name = aws_autoscaling_group.blue.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

resource "aws_autoscaling_policy" "green_cpu" {
  name                   = "cpu-${var.environment}-green"
  autoscaling_group_name = aws_autoscaling_group.green.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
