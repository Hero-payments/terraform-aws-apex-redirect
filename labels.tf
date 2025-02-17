module "labels" {
  source = "github.com/Hero-payments/terraform-aws-labels?ref=v1.1.0"

  name        = "domain-redirection"
  environment = var.environment
  attributes  = []
  managedby   = var.managed_by
  repository  = var.source_repository
  extra_tags  = var.tags
}
