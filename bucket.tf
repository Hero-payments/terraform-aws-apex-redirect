resource "random_id" "bucket" {
  byte_length = 4
}

# One bucket to redirect them all
resource "aws_s3_bucket" "redirect" {
  bucket = "${module.labels.id}-${random_id.bucket.hex}"
  tags   = module.labels.tags
}

resource "aws_s3_bucket_website_configuration" "redirect" {
  bucket = aws_s3_bucket.redirect.id

  redirect_all_requests_to {
    host_name = var.target_domain
    protocol  = var.redirection_schema
  }
}