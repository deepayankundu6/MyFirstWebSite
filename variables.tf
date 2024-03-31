variable "aws_region" {
  type        = string
  description = "Aws region"
}

variable "s3_bucket_name" {
  type        = string
  description = "Bucket name for storing the website"
}

variable "index_file_name" {
  type        = string
  description = "Bucket name for storing the website"
}

variable "website_folder" {
  type        = string
  description = "The folder which contains the website"
}
