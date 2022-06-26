resource "aws_s3_bucket" "cloudfront_access_logs_bucket" {
  bucket = "cloudfront-access-logs-bucket-v2"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "cloudfront-access-logs-bucket-v2"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = var.app_artifact_bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.app_artifact_bucket} OAI"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "support_cf_distribution" {
  origin {
    domain_name = var.app_artifact_bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_access_logs_bucket.bucket_domain_name
    prefix           = "logs/"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }


  ordered_cache_behavior {
    path_pattern     = "/*.*"    # files general path pattern
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = var.lambda_arn
      include_body = true # Send CF Request body to lambda
    }
  }

  price_class = "PriceClass_100"

  retain_on_delete = true

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
#  aliases = [var.domain_name]
#
  viewer_certificate {
#    acm_certificate_arn = var.domain_certificate_arn
#    ssl_support_method  = "sni-only"
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.app_artifact_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = var.app_artifact_bucket
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

module "template_files" {
  source = "hashicorp/dir/template"
  base_dir = var.app_source_dir
}
