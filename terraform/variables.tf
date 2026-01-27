variable "aws_region" { default = "us-east-1" }
variable "app_name" { default = "starttech" }
variable "vpc_cidr" { default = "10.0.0.0/16" }

# Atlas Credentials
variable "mongodbatlas_public_key" {}
variable "mongodbatlas_private_key" {}
variable "atlas_project_id" {}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
#====================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "frontend_bucket_name" {
  description = "S3 bucket name for frontend hosting"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for backend"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum size of Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum size of Auto Scaling Group"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired capacity of Auto Scaling Group"
  type        = number
  default     = 2
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "mongodb_uri" {
  description = "MongoDB connection URI (MongoDB Atlas)"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "alarm_email" {
  description = "Email for CloudWatch alarms"
  type        = string
}