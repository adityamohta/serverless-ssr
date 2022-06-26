provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "ssr-artifacts" {
  bucket = "ssr-artifacts-v2"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "SSR Artifacts"
  }
}

resource "aws_s3_bucket" "app-artifacts" {
  bucket = "ssr-app-artifacts"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "App Artifacts"
  }
}

module "lambda_at_edge" {
  source = "git@github.com:transcend-io/terraform-aws-lambda-at-edge.git"
  name = "react_ssr_handler"
  description = "react_ssr_handler"
  s3_artifact_bucket = aws_s3_bucket.ssr-artifacts.bucket
  lambda_code_source_dir = "${path.module}/app/edge-build"
  handler = "index.handler"
}

module "cloudfront_website" {
  source = "./infra/modules/cloudfront"
  lambda_arn = module.lambda_at_edge.arn
  app_artifact_bucket = aws_s3_bucket.app-artifacts.id
  app_artifact_bucket_arn = aws_s3_bucket.app-artifacts.arn
  app_artifact_bucket_regional_domain_name = aws_s3_bucket.app-artifacts.bucket_regional_domain_name
  app_source_dir = "${path.module}/app/build"
}
