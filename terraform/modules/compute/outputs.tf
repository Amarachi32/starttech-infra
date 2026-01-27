output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The public URL of the load balancer"
}

output "alb_arn_suffix" {
  value       = aws_lb.main.arn_suffix
  description = "Used by the monitoring module for CloudWatch metrics"
}

output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "asg_name" {
  value       = aws_autoscaling_group.app_asg.name
  description = "The name of the Auto Scaling Group"
}