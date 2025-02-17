resource "aws_route53_record" "redirects" {
  for_each = toset(var.source_domains)

  zone_id = aws_route53_zone.zones[each.key].zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.redirects[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.redirects[each.key].hosted_zone_id
    evaluate_target_health = false
  }
}

# One cloudfront per redirected domain
resource "aws_cloudfront_distribution" "redirects" {
  for_each = toset(var.source_domains)

  origin {
    domain_name = aws_s3_bucket_website_configuration.redirect.website_endpoint
    origin_id   = "S3-redirect"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  aliases             = [each.key]
  default_root_object = ""

  default_cache_behavior {
    target_origin_id       = "S3-redirect"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"

  tags       = module.labels.tags
  depends_on = [aws_acm_certificate_validation.cert_validation]
}