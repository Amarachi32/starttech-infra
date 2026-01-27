terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" { # Store state in S3 so team can collaborate
    bucket = "starttech-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" { region = var.aws_region }

module "networking" {
  source = "./modules/networking"
  vpc_cidr = "10.0.0.0/16"
}

module "storage" {
  source      = "./modules/storage"
  bucket_name = "starttech-frontend-prod"
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.networking.vpc_id
  public_subnets     = module.networking.public_subnets
  target_group_arn   = module.compute.target_group_arn
  log_group_name = module.monitoring.log_group_name # Input from Monitoring Output
  instance_type      = "t3.micro"
}
#====================================
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws          = { source = "hashicorp/aws", version = "~> 5.0" }
    mongodbatlas = { source = "mongodb/mongodbatlas", version = "~> 1.10.0" }
  }
}

provider "aws" { region = var.aws_region }

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}

# 1. Networking Module
module "networking" {
  source   = "./modules/networking"
  vpc_cidr = var.vpc_cidr
}

# 2. Monitoring Module (Create Log Groups first for IAM policies)
module "monitoring" {
  source   = "./modules/monitoring"
  app_name = var.app_name
}

# 3. Storage Module (S3 + CloudFront)
module "storage" {
  source      = "./modules/storage"
  bucket_name = "${var.app_name}-frontend-prod"
}

# 4. Compute Module (ASG, ALB, Redis)
module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.networking.vpc_id
  public_subnets     = module.networking.public_subnets
  private_subnets    = module.networking.private_subnets
  log_group_name     = module.monitoring.log_group_name
  instance_type      = "t3.micro"
}

# # ElastiCache Redis
# module "elasticache" {
#   source = "./modules/elasticache"

#   environment        = var.environment
#   vpc_id            = module.networking.vpc_id
#   subnet_ids        = module.networking.private_subnet_ids
#   security_group_ids = [module.networking.redis_security_group_id]
#   node_type         = var.redis_node_type
#   num_cache_nodes   = var.redis_num_nodes
# }