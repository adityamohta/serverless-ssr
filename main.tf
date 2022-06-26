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
  domain_name = "ssr-app.com"
  lambda_arn = module.lambda_at_edge.arn
}
