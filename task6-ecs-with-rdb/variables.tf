variable "region" {
  description = "Region where project will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "az" {
  description = "Availability zones for public subnet"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] 
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pub_subnet_cidr" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "priv_subnet_cidr" {
  description = "Private subnet CIDR block"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string  
  default = "metabase_user"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  default     = "password123" # Change this to a secure password
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "metabase_db" # Change this to your desired database name
}