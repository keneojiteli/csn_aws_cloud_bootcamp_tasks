resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols, allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Security group for ECS service"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"] # use this without lb
    security_groups = [aws_security_group.alb_sg.id] # Allow traffic from the ALB security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols, allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS service"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_sg.id] # Allow traffic from the ECS security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols, allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
