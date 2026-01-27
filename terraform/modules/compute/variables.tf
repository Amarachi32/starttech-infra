variable "vpc_id" { type = string }
variable "public_subnets" { type = list(string) }
variable "instance_type" { default = "t3.micro" }
variable "log_group_name" { type = string }