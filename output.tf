output "nameservers" {
  value = {
    for domain, zone in aws_route53_zone.zones : domain => zone.name_servers
  }
  description = "Nameservers for each Route53 zone"
}