terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # versiune compatibilă cu Terraform v1.13
    }
  }
  required_version = ">= 1.13"
}

provider "aws" {
  region = "eu-central-1"
}

# Bucket S3 existent
data "aws_s3_bucket" "images" {
  bucket = "tatiana-photo-analyzer3"
}

# Cluster ECS existent
data "aws_ecs_cluster" "cluster" {
  cluster_name = "image-analyzer-cluster"
}

# Tag-uri le poți folosi doar în resurse, de exemplu ECS service:
resource "aws_ecs_service" "service" {
  name            = "image-analyzer-service"
  cluster         = data.aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  tags = {
    Project = "Image Analyzer"
    Owner   = "Tatiana"
  }
}
