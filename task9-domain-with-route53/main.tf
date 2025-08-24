# provides a S3 bucket resource
resource "aws_s3_bucket" "csn_bucket_8625_demo" {
  bucket = "my-http-bucket-24825"
  force_destroy = true   # automatically deletes ALL objects when destroying the bucket
  tags = {
    Name        = "csn-bucket-8625-demo"
  }
}

# configures the S3 bucket to be a static website, provides an S3 bucket website configuration resource.
resource "aws_s3_bucket_website_configuration" "bucket_config" {
  bucket = aws_s3_bucket.csn_bucket_8625_demo.bucket
    index_document {
        suffix = "index.html"
    }   
}

# manages s3 bucket-level public access block configuration
resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.csn_bucket_8625_demo.id

  # need to allow public access for the bucket before applying policy
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# attaches a policy to an S3 bucket resource to grant public read access to the objects in the bucket
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.csn_bucket_8625_demo.id

# this policy allows any principal to read/get objects in the specified S3 bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject" # refers to the policy statement ID/name
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject" # allows the action of getting an object ONLY
        Resource  = "${aws_s3_bucket.csn_bucket_8625_demo.arn}/*"
      }
    ]
  })
#   depends_on = [ aws_s3_bucket_public_access_block.bucket_access ]
}

locals {
  website_files = fileset("${path.module}/s3-content", "**")
}

# automate file upload to S3 bucket, using the aws_s3_object resource
resource "aws_s3_object" "website_files" {
  for_each = { for file in local.website_files : file => file }

  bucket       = aws_s3_bucket.csn_bucket_8625_demo.id
  key          = each.value
  source       = "${path.module}/s3-content/${each.value}" # ${path.module} points to the directory where the current .tf file is located
  etag         = filemd5("${path.module}/s3-content/${each.value}")
  content_type = lookup(
    {
      "html" = "text/html",
      "css"  = "text/css",
      "js"   = "application/javascript",
      "png"  = "image/png",
      "jpg"  = "image/jpeg",
      "jpeg" = "image/jpeg",
      "gif"  = "image/gif"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "binary/octet-stream"
  )
}

# request ssl certificate, it will be needed by cloudfront
resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = "keneojiteli.tk"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# creates a DNS zone for my domain
resource "aws_route53_zone" "main" {
  name = "keneojiteli.tk"
}

# creates DNS validation records automatically for ACM
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# finalizes validation once DNS records propagate
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# creates an Amazon CloudFront web distribution
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.csn_bucket_8625_demo.bucket_regional_domain_name # points CloudFront to my bucket
    origin_id   = "s3-origin"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"  # no geo restrictions
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# points my domain to cloudfront
resource "aws_route53_record" "alias" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "keneojiteli.tk"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = true
  }
}

