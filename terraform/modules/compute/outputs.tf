output "alb_dns_name" {
  description = "DNS of the load balancer"
  value       = aws_lb.api.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.app_asg.name
}