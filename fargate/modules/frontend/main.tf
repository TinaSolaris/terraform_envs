resource "aws_security_group" "frontend_sg" {
  name        = "FrontendSGAs7"
  description = "Allow traffic to frontend service"
  vpc_id      = "MY_VPC_ID"

  ingress {
    from_port   = var.frontend_port
    to_port     = var.frontend_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_instance_profile" "existing_instance_profile" {
  name = "LabInstanceProfile"
}

data "aws_iam_role" "existing_instance_role" {
  name = "LabRole"  # Name of the IAM role associated with the instance profile
}


resource "aws_ecs_task_definition" "frontend_task_def" {
  family                   = "FrontendAs7"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.existing_instance_role.arn
  task_role_arn            = data.aws_iam_role.existing_instance_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image_uri
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = var.frontend_port
          hostPort      = var.frontend_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "BACKEND_URL"
          value = "${var.backend_host}:${var.backend_port}"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontend_service" {
  name            = "FrontendSvcAs7"
  cluster         = var.my_cluster_id
  task_definition = aws_ecs_task_definition.frontend_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  enable_ecs_managed_tags = true  # It will tag the network interface with service name
  wait_for_steady_state   = true  # It will wait for the service to reach a steady state before continuing

  network_configuration {
    assign_public_ip = true
    subnets         = [var.subnet_id]
    security_groups = [aws_security_group.frontend_sg.id]
  }
}
