variable "lambda_arn" {
  description = "Lambda Arn"
  type        = string
}

variable app_artifact_bucket {
  description = "Name of the S3 bucket to upload versioned artifacts to"
}

variable app_artifact_bucket_arn {
  description = "ARN of the S3 bucket to upload versioned artifacts to"
}

variable app_artifact_bucket_regional_domain_name {
  description = "Regional domain name of the S3 bucket to upload versioned artifacts to"
}

variable app_source_dir {
  description = "An absolute path to the directory containing the code to upload to app artifacts s3 bucket"
}
