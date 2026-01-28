resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets # ALB needs at least 2 public subnets

  tags = { Name = "${var.app_name}-alb" }
}

#2 also need a Target Group and Listener to make it functional
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.app_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}
#No 3
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
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

# 5. Launch Template (Optimized for GHCR)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "starttech-app-"
  image_id      = var.ami_id
  instance_type = "t3.micro"

  iam_instance_profile { name = var.iam_instance_profile_name }

  # Ensure the instance uses the correct Security Group
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.backend_sg_id]
  }

  user_data = base64encode(<<-EOF
                #!/bin/bash
                # 1. Setup Environment
                echo "MONGODB_URI=${var.mongodb_uri}" >> /etc/environment
                echo "REDIS_URL=${var.redis_endpoint}:6379" >> /etc/environment
                source /etc/environment

                # 2. Install and Start Docker
                yum update -y
                yum install -y docker
                systemctl start docker
                systemctl enable docker
                usermod -a -G docker ec2-user

                # 3. Pull the image (UNCOMMENTED AND FIXED)
                # We use the exact path that worked on your laptop
                docker pull ghcr.io/amarachi32/starttech-app/backend:latest

                # 4. Run the Container
                # -p 8080:8080 maps the ALB traffic to your Go app
                docker run -d \
                  --name backend-api \
                  --restart always \
                  -p 8080:8080 \
                  -e MONGODB_URI="${var.mongodb_uri}" \
                  -e REDIS_URL="${var.redis_endpoint}:6379" \
                  ghcr.io/amarachi32/starttech-app/backend:latest
                EOF
    )
}