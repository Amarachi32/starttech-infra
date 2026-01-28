# # This is the "container" that allows EC2 to use a role
# resource "aws_iam_instance_profile" "app_instance_profile" {
#   name = "starttech-instance-profile" # This must be unique in your AWS account
#   role = aws_iam_role.app_role.name    # Replace with your actual backend IAM role name
# }
# 1. The IAM Role
resource "aws_iam_role" "app_role" {
  name = "starttech-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 2. The Instance Profile (The piece that was erroring)
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "starttech-instance-profile"
  role = aws_iam_role.app_role.name
}

# 3. CloudWatch Logging Permissions (Optional but recommended)
resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}