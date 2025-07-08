variable "region" {
  description = "Region where project will be deployed"
  type        = string
  default     = "us-east-1"
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

variable "ami" {
  description = "AMI for the windows server"
  type        = string
#   default     = "ami-02b60b5095d1e5227" 
#   default     = "ami-00a5deaaa020a9d05" #windows server 2019 sql standard
  default     = "ami-0ed9f8d63c9e8b95a" #windows server 2019 base
  # default = "ami-0c55b159cbfafe1f0" # Example AMI, replace with your own
}