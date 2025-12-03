# ======================
resource "aws_ecs_cluster" "image_analyzer_cluster" {
  name = "tatiana-cluster"
}

# ======================
# ECS Task Definition
# ======================
resource "aws_ecs_task_definition" "image_analyzer_task" {
  family                   = "image-analyzer-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "tatiana-container"
      image     = "${aws_ecr_repository.tatiana_repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/image-analyzer"
          "awslogs-region"        = "eu-central-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ======================
# ECS Service
# ======================
resource "aws_ecs_service" "image_analyzer_service" {
  name            = "tatiana-service"
  cluster         = aws_ecs_cluster.image_analyzer_cluster.id
  task_definition = aws_ecs_task_definition.image_analyzer_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0124030d3021aca7f", "subnet-07780412d1ccfac7f"]
    security_groups  = ["sg-04b68e83acff3730f"]
    assign_public_ip = true
  }
}
