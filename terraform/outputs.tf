output "frontend_url" {
  description = "The URL to access the React application"
  value       = module.storage.cloudfront_domain_name
}

output "backend_api_endpoint" {
  description = "The URL of the Backend API Load Balancer"
  value       = module.compute.alb_dns_name
}

output "cloudfront_dist_id" {
  value = module.storage.cloudfront_distribution_id
}