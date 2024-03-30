resource "aws_s3_bucket" "static" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "static" {
  bucket     = aws_s3_bucket.static.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.meta_static_resources]
}

resource "aws_s3_bucket_public_access_block" "website_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.static.id
  ignore_public_acls      = true
  block_public_acls       = true
  restrict_public_buckets = true
  block_public_policy     = true
}

resource "aws_s3_bucket_ownership_controls" "meta_static_resources" {
  bucket = aws_s3_bucket.static.bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

locals {
  content_type_map = {
    css : "text/css; charset=UTF-8"
    js : "text/js; charset=UTF-8"
    svg : "image/svg+xml"
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
  for_each = fileset("${path.module}/../Website", "**")

  bucket = aws_s3_bucket.static.id
  key    = each.value
  source = "${path.module}/../Website/${each.value}"
  etag   = filemd5("${path.module}/../Website/${each.value}")

  content_type = lookup(
    local.content_type_map,
    split(".", basename(each.value))[length(split(".", basename(each.value))) - 1],
    "text/html; charset=UTF-8",
  )
}