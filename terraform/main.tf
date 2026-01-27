terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" { # Store state in S3 so team can collaborate
    bucket = "starttech-statebucket"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" { region = var.aws_region }

# 1. Networking Module
module "networking" {
  source = "./modules/networking"
  #vpc_cidr = "10.0.0.0/16"
  vpc_cidr = var.vpc_cidr
}

# 2. Monitoring: The Eyes
module "monitoring" {
  source   = "./modules/monitoring"
  app_name = var.app_name
  # These link the alarms to the resources created in 'compute'
  asg_name = module.compute.asg_name
  alb_arn_suffix = module.compute.alb_arn_suffix
}

# 3. Storage: The Frontend
module "storage" {
  source      = "./modules/storage"
  #bucket_name = "starttech-frontend-prod"
  bucket_name = "${var.app_name}-frontend-prod"
}

# 4. Database: The Stateful Layer (Redis)
module "database" {
  source          = "./modules/database"
  app_name        = var.app_name
  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
  backend_sg_id   = module.networking.backend_sg_id # Security dependency - Getting SG from compute
}

# 5. Compute: The Application Layer
module "compute" {
  source             = "./modules/compute"
  app_name           = var.app_name
  vpc_id             = module.networking.vpc_id
  public_subnets     = module.networking.public_subnets
  ami_id             = var.ami_id
  instance_type      = "t3.micro"
  
  # Inputs from Monitoring
  log_group_name     = module.monitoring.log_group_name
  
  # Inputs from Database (The Bridge)
  redis_endpoint     = module.database.redis_endpoint
  
  # Input from Variables (Secret)
  mongodb_uri        = var.mongodb_uri
  alb_sg_id                 = module.networking.alb_sg_id
  backend_sg_id             = module.networking.backend_sg_id
  iam_instance_profile_name = "starttech-instance-profile" # or from an iam module
  github_username           = "Amarachi32"
  github_repo               = "starttech-app"
}
