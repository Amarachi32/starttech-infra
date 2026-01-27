variable "app_name" {
  type        = string
  description = "Name of the application for tagging"
}

variable "vpc_id" {
  type        = string
  description = "The VPC where Redis will live"
}

variable "private_subnets" {
  type        = list(string)
  description = "The private subnets for the Redis subnet group"
}

variable "backend_sg_id" {
  type        = string
  description = "The Security Group ID of the Go Backend to allow traffic to Redis"
}