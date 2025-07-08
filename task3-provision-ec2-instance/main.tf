resource "aws_vpc" "csn_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "csn-vpc"
  }
}

resource "aws_internet_gateway" "csn_igw" {
  vpc_id = aws_vpc.csn_vpc.id

  tags = {
    Name = "csn-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.csn_vpc.id
  cidr_block = var.pub_subnet_cidr
  tags = {
    Name = "csn-public-subnet"
  }
}

resource "aws_route_table" "csn_public_rt" {
  vpc_id = aws_vpc.csn_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.csn_igw.id
  }

  tags = {
    Name = "csn-public-rt"
  }
}

resource "aws_route_table_association" "csn_pub_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.csn_public_rt.id
}


resource "aws_security_group" "csn_sg" {
  name        = "csn-sg"
  description = "Security group for CSN instance"
  vpc_id      = aws_vpc.csn_vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["https://api.ipify.org/>/32"] # Replace with your public IP address 
    # cidr_blocks = ["<YOUR_PUBLIC_IP_FROM_https://api.ipify.org/>/32"] #defines who is allowed to initiate the connection (the source)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "csn-sg"
  }
}

resource "aws_instance" "csn_instance" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.csn_sg.id]
  key_name               = "project-key"
  associate_public_ip_address = true
  tags = {
    Name = "csn-bootcamp-week3"
  }
}

# option to use a module    
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   name    = "csn-vpc"
#   cidr    = "10.0.0.0/16"
#   azs     = ["us-east-1a"]
#   public_subnets  = ["10.0.1.0/24"]
#   enable_nat_gateway = false
#   enable_dns_hostnames = true
# }

