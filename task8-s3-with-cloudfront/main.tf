# provides a S3 bucket resource
resource "aws_s3_bucket" "csn_bucket_8625_demo" {
  bucket = "csn-bucket-8625-demo"
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
    # error_document {
    #     key = "error.html"
    # }   
}

# manages s3 bucket-level public access block configuration
resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.csn_bucket_8625_demo.id

  # need to allow public access for the bucket before applying policy
  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
  ignore_public_acls      = false
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
  depends_on = [ aws_s3_bucket_public_access_block.bucket_access ]
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



# creates an Amazon CloudFront web distribution with S3 as the origin to serve content globally
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.bucket_config.website_endpoint
    origin_id   = "s3-static-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-static-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "StaticSiteCDN"
  }

  # depends_on = [ aws_s3_object.website_files, aws_s3_bucket_policy.website_policy ]
  depends_on = [ aws_s3_object.website_files, aws_s3_bucket_policy.website_policy ]
}