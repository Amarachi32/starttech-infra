# 1. The S3 Bucket (Private)
resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
}

# 2. CloudFront Origin Access Control (The "Key" for CloudFront to enter S3)
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for StartTech Frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 3. The CloudFront Distribution
# resource "aws_cloudfront_distribution" "cdn" {
#   origin {
#     domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
#     origin_id                = "S3Origin"
#     origin_access_control_id = aws_cloudfront_origin_access_control.default.id
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"
#   price_class         = "PriceClass_100"

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "S3Origin"

#     # Fixed syntax: No semicolons, multi-line blocks
#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   # Fixed syntax: Restrictions and Certificate blocks
#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   tags = {
#     Name = "starttech-cdn"
#   }
# }
resource "aws_cloudfront_distribution" "cdn" {
  # Keep your existing S3 Origin
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  # --- ADD THIS: The ALB Origin ---
  origin {
    # Replace with your actual ALB DNS name or a variable
    domain_name = "starttech-alb-1968314094.us-east-1.elb.amazonaws.com"
    origin_id   = "ALBOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only" # Connect to ALB securely
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # --- ADD THIS: The API Routing Logic ---
  # This MUST come before the default_cache_behavior
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "ALBOrigin"

    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]

    # We want to pass the 'Origin' header so your Go code can see it
    forwarded_values {
      query_string = true
      headers      = ["Origin", "Authorization", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 0 # Don't cache API responses
    max_ttl                = 0
  }

  # Your existing default_cache_behavior stays exactly as is
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"
    # ... rest of your code ...
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # ... rest of your restrictions and certificate blocks ...
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# 4. S3 Bucket Policy (Allows OAC to read files)
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}