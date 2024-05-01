resource "aws_security_group" "backend_sg" {
  name        = "BackendSGAs7"
  description = "Allow traffic to backend service"
  vpc_id      = "MY_VPC_ID"

  ingress {
    from_port   = var.backend_port
    to_port     = var.backend_port
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

resource "aws_ecs_task_definition" "backend_task_def" {
  family                   = "BackendAs7"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.existing_instance_role.arn
  task_role_arn            = data.aws_iam_role.existing_instance_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image_uri
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = var.backend_port
          hostPort      = var.backend_port
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "backend_service" {
  name            = "BackendSvcAs7"
  cluster         = var.my_cluster_id
  task_definition = aws_ecs_task_definition.backend_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  enable_ecs_managed_tags = true  # It will tag the network interface with service name
  wait_for_steady_state   = true  # It will wait for the service to reach a steady state before continuing

  network_configuration {
    assign_public_ip = true
    subnets         = [var.subnet_id]
    security_groups = [aws_security_group.backend_sg.id]
  }
}

data "aws_network_interface" "interface_tags" {
  filter {
    name   = "tag:aws:ecs:serviceName"
    values = [aws_ecs_service.backend_service.name]
  }
}