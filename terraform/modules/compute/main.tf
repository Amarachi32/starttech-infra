# 1. Application Load Balancer (Entry Point)
resource "aws_lb" "api" {
  name               = "starttech-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [var.alb_sg_id]
}

# 2. Target Group (Where the ALB sends traffic)
resource "aws_lb_target_group" "app_tg" {
  name     = "starttech-app-tg"
  port     = 8080 # Your Go app port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health" # Ensure your Go app has this route!
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 3. Listener (Listens on Port 80 and forwards to Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 4. Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "app_asg" {
  name                = "starttech-backend-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnets
  target_group_arns   = [aws_lb_target_group.app_tg.arn] # Connects ASG to ALB

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}

# 5. Launch Template (The Blueprint for EC2)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "starttech-app-"
  image_id      = var.ami_id
  instance_type = "t3.micro"

  iam_instance_profile { name = var.iam_instance_profile_name }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "MONGODB_URI=${var.mongodb_uri}" >> /etc/environment
              echo "REDIS_URL=${var.redis_endpoint}:6379" >> /etc/environment
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              EOF
  )
}