terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "MyClusterAs7"
}

module "backend" {
  source = "./modules/backend"
  my_cluster_id = aws_ecs_cluster.my_cluster.id
}

output "backend" {
  value = module.backend
}

module "frontend" {
  source = "./modules/frontend"

  backend_host = module.backend.backend_host
  my_cluster_id = aws_ecs_cluster.my_cluster.id
}
