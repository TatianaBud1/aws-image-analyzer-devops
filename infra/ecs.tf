##############################

#Provider AWS

##############################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.13"
}

provider "aws" {
  region = "eu-central-1"
}

##############################

#Bucket S3 existent

##############################
data "aws_s3_bucket" "images" {
  bucket = "tatiana-photo-analyzer3"
}

##############################

#DynamoDB existent

##############################
data "aws_dynamodb_table" "labels" {
  name = "ImageLabels"
}

##############################

#VPC simplu

##############################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "image-analyzer-vpc"
    Project = "Image Analyzer"
    Owner   = "Tatiana"
  }
}

##############################

#Subnet-uri publice

##############################
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name    = "image-analyzer-subnet-1"
    Project = "Image Analyzer"
    Owner   = "Tatiana"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"

  tags = {
    Name    = "image-analyzer-subnet-2"
    Project = "Image Analyzer"
    Owner   = "Tatiana"
  }
}

##############################

#Security Group ECS

##############################
resource "aws_security_group" "ecs_sg" {
  name        = "image-analyzer-sg"
  description = "Allow traffic to ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "Image Analyzer"
    Owner   = "Tatiana"
  }
}

##############################

#ECS Cluster

##############################
resource "aws_ecs_cluster" "main_new" {
  name = "image-analyzer-cluster-new"

  tags = {
    Project = "Image Analyzer"
    Owner   = "Tatiana"
  }
}

##############################

#IAM Role pentru Fargate

##############################
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws/service-role/AmazonECSTaskExecutionRolePolicy"
}

##############################

#ECS Task Definition

##############################
resource "aws_ecs_task_definition" "task" {
  family                   = "image-analyzer-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "api"
      image = "914894372597.dkr.ecr.eu-central-1.amazonaws.com/aws-image-analizer-devops"
      portMappings = [
        {
          containerPort = 8000
        }
      ]
      environment = [
        {
          name  = "S3_BUCKET"
          value = data.aws_s3_bucket.images.bucket
        },
        {
          name  = "DYNAMO_TABLE"
          value = data.aws_dynamodb_table.labels.name
        }
      ]
    }
  ])
}

##############################

#ECS Service

##############################
resource "aws_ecs_service" "service" {
  name            = "image-analyzer-service"
  cluster         = aws_ecs_cluster.main_new.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  tags = {
    Project = "Image Analyzer"
    Owner   = "Tatiana"
  }
}
