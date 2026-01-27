output "log_group_name" {
  value = aws_cloudwatch_log_group.app_logs.name
}
output "asg_name" {
  value       = var.asg_name
  description = "The name of the Auto Scaling Group"
}
