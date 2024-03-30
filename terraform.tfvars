variable "aws_region" {
  default     = "ap-south-1"
  type        = string
  description = "Aws region"
}

variable "s3_bucket_name" {
  default     = "deeps-my-website-002"
  type        = string
  description = "Bucket name for storing the website"
}
