terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  # versiune compatibilă cu Terraform v1.13
    }
  }
  required_version = ">= 1.13"
}

provider "aws" {
  region = "eu-central-1"
}

# Bucket S3 existent
resource "aws_s3_bucket" "images" {
  bucket = "tatiana-photo-analyzer3"
}

# Cluster ECS
resource "aws_ecs_cluster" "cluster" {
  name = "image-analyzer-cluster"
  tags = {
    Project = "Image Analyzer"
    Owner   = "Tatiana"
  }
}