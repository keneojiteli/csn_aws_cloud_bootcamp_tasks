# implement logging
resource "aws_cloudwatch_log_group" "metabase" {
  name              = "watch"
  retention_in_days = 7
}

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
  cpu                      = "1024"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  

  container_definitions = jsonencode([{
    name      = "ecs-container"
    image     = "metabase/metabase:latest"  
    cpu       = 1024
    memory    = 4096
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "MB_DB_TYPE"
        value = "postgres"
      },
      {
        name  = "MB_DB_HOST"
        value = aws_db_instance.my_db.endpoint # rds endpoint, change attribute from address to endpoint
        # value = "postgres-db.ckdksg0ommml.us-east-1.rds.amazonaws.com" # rds endpoint, change attribute from address to endpoint
      },
      {
        name  = "MB_DB_PORT"
        value = "5432"
      },
      {
        name  = "MB_DB_USER"
        value = var.db_username
      },
      {
        name  = "MB_DB_PASS"
        value = var.db_password
      },
      {
        name  = "MB_DB_NAME"
        value = var.db_name
      }
    ]
  logConfiguration = {
    logDriver = "awslogs",
    options = {
          awslogs-group         = aws_cloudwatch_log_group.metabase.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
    }
  }
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
    health_check_grace_period_seconds = 120
    
    network_configuration {
        subnets          = [for s in aws_subnet.public_subnet : s.id]
        security_groups  = [aws_security_group.ecs_sg.id]
        assign_public_ip = true
    }
    
    load_balancer {
        target_group_arn = aws_lb_target_group.lb_tg.arn
        container_name   = "ecs-container"
        container_port   = 3000
    }
   depends_on = [aws_lb.ecs_lb, aws_lb_listener.lb_listener, aws_db_instance.my_db]
   
    tags = {
        Name = "ecs-service"
    }
}

