
variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "lambda_arn" {
  description = "Lambda Arn"
  type        = string
}

#variable "domain_cname" {
#  description = "Domain C Name"
#  type        = string
#}
#
#variable "domain_certificate_arn" {
#  description = "Domain Certificate ARN (Must be present in us-east-1)"
#  type        = string
#}
#
#variable "domain_zone_id" {
#  description = "Domain Certificate ARN (Must be present in us-east-1)"
#  type        = string
#}