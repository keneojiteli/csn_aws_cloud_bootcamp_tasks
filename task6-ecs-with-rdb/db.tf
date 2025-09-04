# provides an RDS DB subnet group resource (private subnet), a single resource that can take multiple subnets
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "rds-subnet-group"
  }
}

# # provides an RDS instance resource
resource "aws_db_instance" "my_db" {
  identifier              = "postgres-db"
  engine                  = "postgres"
  engine_version          = "16.6"   # check AWS supported versions
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  # vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  vpc_security_group_ids  = [aws_security_group.ecs_sg.id]
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  skip_final_snapshot     = true
  publicly_accessible     = false #keeps the RDS instance private and can be reached bu ecs task, db resides in private subnet

  tags = {
    Name = "my_db"
  }
}

