# provides a load balancer resource
resource "aws_lb" "ecs_lb" {
  name               = "ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public_subnet: s.id]

  enable_deletion_protection = false # enables terraform to delete lb

  tags = {
    Name = "ecs-lb"
  }
}

# provides a target group resource for use with load balancer resources, routes traffic from the ALB listener to the ECS container
resource "aws_lb_target_group" "lb_tg" {
  name = "ecs-tg"
  port = 3000
  protocol = "HTTP"
  target_type = "ip" # use ip for fargate tasks
  vpc_id = aws_vpc.ecs_vpc.id

  health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200-399" # HTTP status codes to consider healthy
    }
    
  tags = {
    Name = "lb-tg"
  }
}

# provides a load balancer listener resource to listen for client's request, routes to targets in a target grp
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port = 80 # listens on either port 80 /443
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
  tags = {
    Name = "lb-listener"
  }
}