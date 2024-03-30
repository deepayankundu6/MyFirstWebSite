resource "aws_s3_bucket" "static" {
  // important to provide a global unique bucket name
  bucket = var.s3_bucket_name
}