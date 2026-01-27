resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Lowest cost (US, Canada, Europe)

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values { query_string = false; cookies { forward = "none" } }
  }
  
  viewer_certificate { cloudfront_default_certificate = true }
  restrictions { geo_restriction { restriction_type = "none" } }
}