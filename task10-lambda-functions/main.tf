# # create an S3 bucket with a globally unique name to trigger the Lambda function
# resource "aws_s3_bucket" "lambda_trigger_bucket" {
#   bucket = var.bucket_name
#   force_destroy = true

#   tags = {
#     Name        = "LambdaTriggerBucket"
#   }
# }

# # upload a test file automatically after apply
# resource "aws_s3_object" "lambda_zip" {
#   bucket = aws_s3_bucket.lambda_trigger_bucket.id
#   key    = "lambda.zip"
#   source = data.archive_file.lambda_zip.output_path
#   depends_on = [aws_lambda_function.s3_trigger_lambda] # ensure Lambda is ready
# }

# # block public access to the S3 bucket
# resource "aws_s3_bucket_public_access_block" "uploads" {
#   bucket                  = aws_s3_bucket.lambda_trigger_bucket.id
#   block_public_acls       = true
#   block_public_policy     = true
#   restrict_public_buckets = true
#   ignore_public_acls      = true
#   # depends_on = [ aws_iam_role.lambda_exec_role, aws_iam_role_policy_attachment.lambda_logs_policy ]
# }

# # auto-zips my Lambda code/script so Terraform can package and deploy it
# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/lambda" # directory containing the lambda-fxn.py file, points to the directory where the current .tf file is located
#   output_path = "${path.module}/lambda/lambda-fxn.zip"
# }

# # iam role the Lambda function will assume when it is executed
# resource "aws_iam_role" "lambda_exec_role" {
#   name = "lambda_execution_role"
  
#   assume_role_policy = jsonencode({
#   Version = "2012-10-17",
#   Statement = [
#     {
#       Effect = "Allow",
#       Principal = {
#         Service = "lambda.amazonaws.com" # only lambda can use this role
#       }
#       Action = "sts:AssumeRole"
#     }
#   ]
# })
# }

# # attach policy to the role to allow lambda to write logs to CloudWatch and read from S3
# # resource "aws_iam_role_policy" "lambda_policy" {
# #   role = aws_iam_role.lambda_exec_role.id
# #   policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect   = "Allow"
# #         Action   = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
# #         Resource = "*"
# #       },
# #       {
# #         Effect   = "Allow"
# #         Action   = ["s3:GetObject"]
# #         Resource = "${aws_s3_bucket.lambda_trigger_bucket.arn}/*"
# #       }
# #     ]
# #   })
# # }

# # ensures lambda print messages in CloudWatch Logs
# resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
#   role       = aws_iam_role.lambda_exec_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }



# # resource "aws_iam_role_policy_attachment" "lambda_s3_policy" {
# #   role       = aws_iam_role.lambda_exec_role.name
# #   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# # }

# # permission to send email using SES
# resource "aws_iam_role_policy" "lambda_ses_send" {
#   name = "lambda-ses-send"
#   role = aws_iam_role.lambda_exec_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect: "Allow",
#       Action: ["ses:SendEmail", "ses:SendRawEmail"],
#       Resource: "*"
#     }]
#   })
# }


# # creates a lambda function
# resource "aws_lambda_function" "s3_trigger_lambda" {
#   function_name = "s3_trigger_lambda"
#   role          = aws_iam_role.lambda_exec_role.arn
#   handler       = "lambda-fxn.lambda_handler" # file name.function name 
#   runtime       = "python3.13"
#   filename      = "${path.module}/lambda/lambda-fxn.zip" # path to zipped file
# #   filename    = data.archive_file.lambda_zip.output_path # path to zipped file
#   source_code_hash = data.archive_file.lambda_zip.output_base64sha256
# }

# # control log retention for the Lambda's log group
# resource "aws_cloudwatch_log_group" "lambda_logs" {
#   name              = "/aws/lambda/${aws_lambda_function.s3_trigger_lambda.function_name}"
#   retention_in_days = var.log_retention_period
# }

# # allows s3 to invoke lambda, without this, the S3 bucket would be blocked from invoking the Lambda function
# resource "aws_lambda_permission" "allow_s3" {
#   statement_id  = "AllowS3Invoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.s3_trigger_lambda.function_name
#   principal     = "s3.amazonaws.com" # service that can invoke lambda
#   source_arn    = aws_s3_bucket.lambda_trigger_bucket.arn
# }

# # links bucket to lambda, permission above needs to exist first before this takes place 
# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = aws_s3_bucket.lambda_trigger_bucket.id

#   # connects S3 events to lambda
#   lambda_function {
#     lambda_function_arn = aws_lambda_function.s3_trigger_lambda.arn
#     events              = ["s3:ObjectCreated:*"]
#   }
#   depends_on = [aws_lambda_permission.allow_s3]
# }

# # provides an SES email identity resource, AWS sends a verification email to this address
# resource "aws_ses_email_identity" "from_email" {
#   email = "kenechukwuojiteli@gmail.com"
# }



