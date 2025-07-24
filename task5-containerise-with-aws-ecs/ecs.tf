# provides an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
  tags = {
    Name = "ecs-cluster"
  } 
}

# provides a task definition for the ECS service
# a task definition is a blueprint for your application, it describes one or more containers that form your application
resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "ecs-task-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  

  container_definitions = jsonencode([{
    name      = "ecs-container"
    image     = "grafana/grafana"  
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }]
  }])

  tags = {
    Name = "ecs-task-def"
  }
  
}
# a task expected to run until an error occurs or a user terminates it
resource "aws_ecs_service" "ecs_service" {
    name            = "ecs-service"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.ecs_task_def.arn
    desired_count   = 1
    launch_type     = "FARGATE"
    platform_version = "LATEST" # default value, can be omitted, only for Fargate launch type
    
    network_configuration {
        subnets          = [aws_subnet.public_subnet.id]
        security_groups  = [aws_security_group.ecs_sg.id]
        assign_public_ip = true
    }
    
    # load_balancer {
    #     target_group_arn = aws_lb_target_group.ecs_target_group.arn
    #     container_name   = "ecs-container"
    #     container_port   = 80
    # }
    
    tags = {
        Name = "ecs-service"
    }
}