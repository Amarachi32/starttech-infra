# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.app_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.app_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.app_name}-tg"
  }
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "starttech-backend-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnets
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.app_name}-asg"
    propagate_at_launch = true
  }
}

# Launch Template
resource "aws_launch_template" "app_lt" {
  name_prefix   = "starttech-app-"
  image_id      = var.ami_id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.backend_sg_id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Setup Environment
    echo "MONGODB_URI=${var.mongodb_uri}" >> /etc/environment
    echo "REDIS_URL=${var.redis_endpoint}:6379" >> /etc/environment
    source /etc/environment

    # Install and Start Docker
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user

    # Pull the image
    docker pull ghcr.io/amarachi32/starttech-app/backend:latest

    # Run the Container
    docker run -d \
      --name backend-api \
      --restart always \
      -p 8080:8080 \
      -e PORT=8080 \
      -e MONGODB_URI='${var.mongodb_uri}' \
      -e REDIS_ADDR='${var.redis_endpoint}:6379' \
      ghcr.io/amarachi32/starttech-app/backend:latest
  EOF
  )
}


# # 5. Launch Template (The Blueprint for EC2)
# resource "aws_launch_template" "app_lt" {
#   name_prefix   = "starttech-app-"
#   image_id      = var.ami_id
#   instance_type = "t3.micro"

#   iam_instance_profile { name = var.iam_instance_profile_name }

#   user_data = base64encode(<<-EOF
#               #!/bin/bash
#               echo "MONGODB_URI=${var.mongodb_uri}" >> /etc/environment
#               echo "REDIS_URL=${var.redis_endpoint}:6379" >> /etc/environment
#               yum update -y
#               amazon-linux-extras install docker -y
#               service docker start
#               EOF
#   )
# }
