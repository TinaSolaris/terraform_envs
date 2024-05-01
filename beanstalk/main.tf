terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1"
    }
  }
  required_version = ">= 1.2.0"
}

# Define provider (AWS)
provider "aws" {
  region = "us-east-1"
}

# Backend Module
module "backend" {
  source = "./modules/backend"
}

output "backend" {
  value = module.backend
}

# Frontend Module
module "frontend" {
  source        = "./modules/frontend"
  backend_url   = module.backend.backend_elastic_beanstalk_url
}
