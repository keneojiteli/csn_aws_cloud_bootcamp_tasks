resource "aws_vpc" "csn_vpc" {
  count = length(var.vpc_cidr)
  cidr_block           = element(var.vpc_cidr, count.index)
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-${var.tag[count.index]}"
  }
}


resource "aws_subnet" "public_subnet" {
  count = length(var.pub_subnet_cidr)
  availability_zone = element(var.az, count.index)
  vpc_id     = element(aws_vpc.csn_vpc.*.id, count.index)
  cidr_block = element(var.pub_subnet_cidr, count.index)
  tags = {
    Name = "public-subnet-${var.tag[count.index]}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.priv_subnet_cidr)
  availability_zone = element(var.az, count.index)
  vpc_id     = element(aws_vpc.csn_vpc.*.id, count.index)
  cidr_block = element(var.priv_subnet_cidr, count.index)
  tags = {
    Name = "private-subnet-${var.tag[count.index]}"
  }
}

# route table holds a list of rules (routes) for where to send network traffic
resource "aws_route_table" "vpc_rt" {
  count = length(var.vpc_cidr)
  vpc_id = aws_vpc.csn_vpc[count.index].id

  tags = {
    Name = "rt-table-VPC-${var.tag[count.index]}"
  }
}

# links public subnet to route table
resource "aws_route_table_association" "pub_rtb_assoc" {
  count = length(var.pub_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.vpc_rt[count.index].id
  depends_on = [aws_subnet.public_subnet, aws_route_table.vpc_rt]
}

# links private subnet to route table
resource "aws_route_table_association" "priv_rtb_assoc" {
  count = length(var.priv_subnet_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.vpc_rt[count.index].id
  depends_on = [aws_subnet.private_subnet, aws_route_table.vpc_rt]
}

resource "aws_vpc_peering_connection" "vpc_peering" {
  # peer_owner_id = var.aws_id
  vpc_id        = aws_vpc.csn_vpc[0].id
  peer_vpc_id   = aws_vpc.csn_vpc[1].id
  auto_accept = true
  tags = {
    Name = "VPC-${var.tag[0]}-to-VPC-${var.tag[1]}"
  }
}

resource "aws_route" "vpc_a_to_b" {
  count = length(var.vpc_cidr)
  route_table_id         = aws_route_table.vpc_rt[count.index].id
  destination_cidr_block = element(var.vpc_cidr, (count.index + 1) % length(var.vpc_cidr))
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  
}

# the resources below are used for testing but won't work without an internet gateway and NAT gateway setup

# resource "aws_security_group" "instance_sg" {
#   count = length(var.vpc_cidr)
#   vpc_id      = aws_vpc.csn_vpc[count.index].id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.vpc_cidr[count.index]] # Replace with your public IP address 
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["replace-with-ur-IP/32"]
#   }

#   tags = {
#     Name = "sg-for-vpc-${var.tag[count.index]}"
#   }
# }

# resource "aws_instance" "vpc_instance" {
#   count                  = length(var.pub_subnet_cidr)
#   ami                    = var.ami
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public_subnet[count.index].id
#   vpc_security_group_ids = [aws_security_group.instance_sg[count.index].id]
#   key_name               = "project-key"
#   associate_public_ip_address = true
#   tags = {
#     Name = "instance-for-vpc-${var.tag[count.index]}"
#   }
# }


