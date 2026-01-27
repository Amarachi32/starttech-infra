# 1. Centralized Log Group for the Golang Backend
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${var.app_name}-backend"
  retention_in_days = 1

  tags = {
    Environment = "production"
    Application = var.app_name
  }
}

# 2. Metric Alarm: High CPU Utilization for Auto Scaling
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.app_name}-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60" # 1 minute
  statistic           = "Average"
  threshold           = "70" # 70% CPU threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# 3. Metric Alarm: ALB 5XX Errors
# This alerts us if the Golang backend starts crashing
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.app_name}-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert when backend returns high 5XX errors"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}