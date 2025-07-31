variable "region" {
  description = "Region where project will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "az" {
  description = "Availability zone for public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pub_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

