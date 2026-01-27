# --- General Project Variables ---
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application used for naming resources"
  type        = string
  default     = "starttech"
}

# --- Networking Variables ---
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# --- Compute Variables ---
variable "ami_id" {
  description = "The AMI ID for EC2 instances (Amazon Linux 2023 recommended)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# --- Secrets & External Integrations ---
variable "mongodb_uri" {
  description = "The connection string from MongoDB Atlas"
  type        = string
  sensitive   = true # Prevents the URI from being logged in the terminal
}