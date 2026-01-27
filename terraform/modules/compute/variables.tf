#variable "instance_type" { default = "t3.micro" }
#variable "log_group_name" { type = string }

variable "app_name" {
  type        = string
  description = "The name of the application"
}

variable "ami_id" {
  type        = string
  description = "The Amazon Machine Image ID for the EC2 instances"
}

variable "mongodb_uri" {
  type        = string
  description = "The connection string for MongoDB"
  sensitive   = true
}

variable "redis_endpoint" {
  type        = string
  description = "The endpoint/address of the Redis cluster"
}

# Ensure you also have these if you are using them in main.tf:
variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "backend_sg_id" {
  type = string
}

variable "iam_instance_profile_name" {
  type = string
}

variable "github_username" {
  type = string
}

variable "github_repo" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "log_group_name" {
  type        = string
  description = "Name of the CloudWatch log group"
}