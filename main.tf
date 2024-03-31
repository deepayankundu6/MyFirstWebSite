resource "aws_s3_bucket" "static" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "open_access" {
  bucket = aws_s3_bucket.static.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Public_access"
    Statement = [
      {
        Sid = "IPAllow"
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.static.arn}/${var.index_file_name}"
      },
    ]
  })
  depends_on = [ aws_s3_bucket_public_access_block.website_bucket_public_access_block ]
}

resource "aws_s3_bucket_acl" "static" {
  bucket     = aws_s3_bucket.static.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.meta_static_resources, aws_s3_bucket_public_access_block.website_bucket_public_access_block]
}

resource "aws_s3_bucket_public_access_block" "website_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.static.id
  ignore_public_acls      = false
  block_public_acls       = false
  restrict_public_buckets = false
  block_public_policy     = false
}

resource "aws_s3_bucket_ownership_controls" "meta_static_resources" {
  bucket = aws_s3_bucket.static.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

locals {
  content_type_map = {
    css : "text/css; charset=UTF-8"
    js : "text/javascript; charset=UTF-8"
    svg : "image/svg+xml"
    jpg : "image/jpeg"
    gif : "image/gif"
    png : "image/png"
    html : "application/xhtml+xml"
  }
}

resource "aws_s3_bucket_website_configuration" "static" {
  bucket = aws_s3_bucket.static.id

  index_document {
    suffix = var.index_file_name
  }

  routing_rule {
    redirect {
      replace_key_with = var.index_file_name
    }
  }
}

resource "aws_s3_object" "assets" {
  for_each = fileset("${path.module}${var.website_folder}", "*")

  bucket = aws_s3_bucket.static.id
  key    = each.value
  source = "${path.module}${var.website_folder}/${each.value}"
  etag   = filemd5("${path.module}${var.website_folder}/${each.value}")

  content_type = lookup(
    local.content_type_map,
    split(".", basename(each.value))[length(split(".", basename(each.value))) - 1],
    "application/octet-stream",
  )
}