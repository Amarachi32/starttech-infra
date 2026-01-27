# Security Group for Redis
resource "aws_security_group" "redis_sg" {
  name        = "${var.app_name}-redis-sg"
  vpc_id      = var.vpc_id
  description = "Allow traffic from backend to Redis"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.backend_sg_id] # Only allows the Backend to talk to Redis
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Redis Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.app_name}-redis-subnets"
  subnet_ids = var.private_subnets
}

# ElastiCache Redis Cluster (Free Tier eligible: cache.t3.micro)
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.app_name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  security_group_ids   = [aws_security_group.redis_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.main.name
}