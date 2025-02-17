resource "aws_acm_certificate" "cert" {
  domain_name               = var.source_domains[0]
  subject_alternative_names = slice(var.source_domains, 1, length(var.source_domains))
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validations" {
  for_each = {
    for domain in var.source_domains : domain => {
      zone_id = aws_route53_zone.zones[domain].zone_id
    }
  }

  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[index(var.source_domains, each.key)].resource_record_name
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[index(var.source_domains, each.key)].resource_record_value]
  ttl             = 60
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[index(var.source_domains, each.key)].resource_record_type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validations : record.fqdn]
}