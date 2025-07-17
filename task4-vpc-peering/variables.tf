variable "region" {
  description = "Region where project will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "az" {
  description = "Availability zones where each vpc will be deployed"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# variable "aws_id" {
#   description = "AWS account ID for the peering connection"
#   type        = string
#   default     = "248189923162" # Replace with your actual AWS account ID
# }

variable "vpc_cidr" {
  description = "CIDR block for the VPCs"
  type        = list(string)
  default     = ["10.10.0.0/16", "10.20.0.0/16"]
}

variable "pub_subnet_cidr" {
  description = "Public subnet CIDR block for each VPC"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.20.1.0/24"]
}

variable "priv_subnet_cidr" {
  description = "Private subnet CIDR block for each VPC"
  type        = list(string)
  default     = ["10.10.2.0/24", "10.20.2.0/24"]
}

variable "tag" {
  description = "value for the resource tag"
  type        = list(string)
  default     = ["A", "B"]
}

variable "ami" {
    description = "AMI for the bastion & private host"
    type = string
    default = "ami-0150ccaf51ab55a51" # Example AMI, replace with your own
}

