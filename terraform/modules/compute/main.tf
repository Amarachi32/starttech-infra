# Launch Template for EC2
resource "aws_launch_template" "app_lt" {
  name_prefix   = "starttech-app-"
  image_id      = var.ami_id # Amazon Linux 2
  instance_type = "t3.micro"

  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              # CloudWatch Agent Setup here
              EOF
  )
}
#-=====================------------------=====================

# IAM Role for EC2 to write to CloudWatch
resource "aws_iam_role" "ec2_role" {
  name = "starttech-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_logs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Application Load Balancer
resource "aws_lb" "api" {
  name               = "starttech-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

# Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "app_asg" {
  name                = "starttech-backend-asg"
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnets # Public subnets to stay in Free Tier (avoids NAT Gateway cost)
  #target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}

# ElastiCache Redis (Free Tier Eligible: cache.t3.micro)
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "starttech-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnets.name
}