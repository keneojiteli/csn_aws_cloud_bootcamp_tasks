variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "my-lambda-bucket-22825" 
}

variable "log_retention_period" {
  description = "CloudWatch Logs retention period for the Lambda log group"
  type        = number
  default     = 7
}