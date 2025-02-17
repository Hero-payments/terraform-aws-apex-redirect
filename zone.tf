# Zones Route53
resource "aws_route53_zone" "zones" {
  for_each = toset(var.source_domains)
  name     = each.key
  tags     = module.labels.tags
}