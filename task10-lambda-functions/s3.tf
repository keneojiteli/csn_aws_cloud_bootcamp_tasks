# create an S3 bucket with a globally unique name to trigger the Lambda function
resource "aws_s3_bucket" "lambda_trigger_bucket" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name        = "LambdaTriggerBucket"
  }
}

# upload a test file automatically after apply
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.id
  key    = "lambda.zip"
  source = data.archive_file.lambda_zip.output_path
  depends_on = [aws_lambda_function.s3_trigger_lambda] # ensure Lambda is ready
}

# block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.lambda_trigger_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  # depends_on = [ aws_iam_role.lambda_exec_role, aws_iam_role_policy_attachment.lambda_logs_policy ]
}

# auto-zips my Lambda code/script so Terraform can package and deploy it
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda" # directory containing the lambda-fxn.py file, points to the directory where the current .tf file is located
  output_path = "${path.module}/lambda/lambda-fxn.zip"
}

# links bucket to lambda, lambda permission needs to exist before this takes place 
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.id

  # connects S3 events to lambda
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_trigger_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".zip"   
  }
  depends_on = [aws_lambda_permission.allow_s3]
}