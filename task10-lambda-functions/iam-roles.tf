# iam role the Lambda function will assume when it is executed
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"
  
  assume_role_policy = jsonencode({
  Version = "2012-10-17",
  Statement = [
    {
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com" # only lambda can use this role
      }
      Action = "sts:AssumeRole"
    }
  ]
})
}

# IAM Policy allows Lambda to use SES & CloudWatch Logs
resource "aws_iam_policy" "lambda_ses_policy" {
  name        = "lambda_ses_policy"
  description = "Policy to allow Lambda to use SES and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# attaches the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_ses_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
}

# # ensures lambda print messages in CloudWatch Logs
# resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
#   role       = aws_iam_role.lambda_exec_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

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

# resource "aws_iam_role_policy" "lambda_ses_policy" {
#   name = "lambda_ses_policy"
#   role = aws_iam_role.lambda_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "ses:SendEmail",
#           "ses:SendRawEmail"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       }
#     ]
#   })
# }






