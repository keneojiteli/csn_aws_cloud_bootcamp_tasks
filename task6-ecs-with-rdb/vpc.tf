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
  count = length(var.pub_subnet_cidr)
  cidr_block = var.pub_subnet_cidr[count.index]
  availability_zone = var.az[count.index]
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
  count = length(var.pub_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.vpc_rt.id
  depends_on = [aws_subnet.public_subnet, aws_route_table.vpc_rt]
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.ecs_vpc.id
  count = length(var.priv_subnet_cidr)
  cidr_block = var.priv_subnet_cidr[count.index]
  availability_zone = var.az[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "ecs-private-subnet"
  }
}

