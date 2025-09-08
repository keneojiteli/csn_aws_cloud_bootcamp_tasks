# creates a lambda function
resource "aws_lambda_function" "s3_trigger_lambda" {
  function_name = "s3_trigger_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda-fxn.lambda_handler" # file name.function name 
  runtime       = "python3.13"
  filename      = "${path.module}/lambda/lambda-fxn.zip" # path to zipped file
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment{
    variables = {
        SES_FROM = "kenechukwuojiteli@gmail.com"
        SES_TO   = "kenechukwuojiteli@gmail.com"
        LOG_LEVEL = "INFO"
    }
  }
}

# allows s3 to invoke lambda, without this, the S3 bucket would be blocked from invoking the Lambda function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_trigger_lambda.function_name
  principal     = "s3.amazonaws.com" # service that can invoke lambda
  source_arn    = aws_s3_bucket.lambda_trigger_bucket.arn
}

# resource "null_resource" "trigger_lambda" {
#   provisioner "local-exec" {
#     command = "aws lambda invoke --function-name s3_trigger_lambda --region us-east-1 response.json"
#   }

#   depends_on = [aws_lambda_function.s3_trigger_lambda]
# }


# control log retention for the Lambda's log group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.s3_trigger_lambda.function_name}"
  retention_in_days = var.log_retention_period
}