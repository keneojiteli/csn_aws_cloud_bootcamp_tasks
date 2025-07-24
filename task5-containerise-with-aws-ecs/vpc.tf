resource "aws_vpc" "ecs_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "ecs-vpc"
  }
}


resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags = {
    Name = "ecs-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.ecs_vpc.id
  cidr_block = var.pub_subnet_cidr
  availability_zone = var.az
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs-public-subnet"
  }
}

resource "aws_route_table" "vpc_rt" {
  vpc_id = aws_vpc.ecs_vpc.id

  # this route allows outbound traffic to the internet via the internet gateway, shows its a pub subnet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }

  tags = {
    Name = "ecs-rt-table"
  }
}

# links public subnet to route table
resource "aws_route_table_association" "pub_rtb_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.vpc_rt.id
  depends_on = [aws_subnet.public_subnet, aws_route_table.vpc_rt]
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Security group for ECS service"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    # cidr_blocks = ["https://api.ipify.org/>/32"] # Uncomment and replace with your IP for security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # cidr_blocks = ["https://api.ipify.org/>/32"] # Uncomment and replace with your IP for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols, allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.21.0" # Always check for the latest version

#   name = "ecs-vpc"
#   cidr = var.vpc_cidr

#   azs             = var.az
#   public_subnets  = var.pub_subnet_cidr

#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   enable_nat_gateway = false         # Not needed for just public subnets
#   single_nat_gateway = false

# #   enable_internet_gateway = true

#   tags = {
#     Name        = "ecs-vpc"
#   }
# }

