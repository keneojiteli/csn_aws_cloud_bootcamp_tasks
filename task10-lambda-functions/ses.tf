# provides an SES email identity resource, AWS sends a verification email to this address
resource "aws_ses_email_identity" "from_email" {
  email = "kenechukwuojiteli@gmail.com"
}