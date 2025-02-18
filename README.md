# AWS Apex Domain Redirections

## Description
This Terraform project sets up HTTPS redirections for apex domains (naked domains) to a single destination domain. It leverages AWS Route53, S3, CloudFront, and ACM to create a robust and secure infrastructure.

## Architecture
The deployed infrastructure includes:
- One Route53 zone per source domain
- A DNS records for each domain pointing to a CloudFront distribution
- One CloudFront distribution
- An SSL/TLS certificate (ACM) covering all source domains
- A single S3 bucket configured as a website for redirection

## Prerequisites
- Terraform >= 1.10.3
- AWS CLI configured with appropriate permissions
- Registered apex domains you want to redirect
- Ability to configure NS records at your domain registrar

## Usage

1. Create a `terraform.tfvars` file:
```hcl
source_domains     = ["example.com", "example.net", "example.org"]
target_domain      = "www.destination.com"
```

2. Initialize Terraform:
```bash
terraform init
```

3. Check execution plan:
```bash
terraform plan
```

4. Apply configuration:
```bash
terraform apply
```

5. Configure your domains' NS:
    - Get nameservers from Terraform output
    - Update NS records at your registrar
    - Wait for DNS propagation (up to 48h)

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| target_domain | The name of the domain to redirect to | `string` | n/a |   yes    |
| source_domains | List of apex domains that should redirect. Must be apex domains (e.g., example.com) | `list(string)` | n/a |   yes    |
| redirection_schema | The schema to use for the redirection (http or https) | `string` | `"https"` |    no    |
| managed_by | The team responsible for managing the resources | `string` | `"platform"` |    no    |
| environment | The environment the resources are deployed to | `string` | `"prod"` |    no    |
| tags | Extra tags to add to the created resources | `map(string)` | `{}` |    no    |
| source_repository | The repository calling this module | `string` | "" |   no    |

### Example Usage

```hcl
module "domain_redirections" {
  source = "path/to/module"

  target_domain      = "www.destination.com"
  source_domains     = ["example.com", "example.net"]
  redirection_schema = "https"
  managed_by         = "platform"
  environment        = "prod"
  source_repository  = "https://github.com/Hero-payments/terraform-aws-apex-redirect"

  tags = {
    CostCenter = "123456"
    Project    = "domain-consolidation"
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| nameservers | Map of nameservers for each created Route53 zone |

## Deployment Time
- Initial infrastructure creation: ~10 minutes
- ACM certificate validation: up to 30 minutes
- Complete DNS propagation: up to 48 hours

## Limitations
- Supports apex domains only (no subdomains)
- Maximum 100 source domains (ACM SAN limit)
- CloudFront distribution limited to PriceClass_100 (North America, Europe)

## Costs
Main monthly costs will be related to:
- Route53 zone hosting ($0.50 per zone/month)
- CloudFront requests (usage-based pricing)
- ACM certificate (free)
- S3 bucket (negligible cost)

## Security
- All traffic encrypted via HTTPS
- DNS validation for SSL/TLS certificates
- Automatic HTTP to HTTPS redirection


## Troubleshooting
Common issues:
1. **ACM validation fails**: Check that DNS validation records are properly created
2. **Domain unreachable**: Verify NS configuration at your registrar
3. **SSL error**: Wait for complete certificate propagation

## Local Development
1. Clone the repository
2. Create a `terraform.tfvars` file
3. Initialize Terraform
4. Run plan/apply

## Contributing
1. Fork the project
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
MIT

## Authors
Louis Holleville <louis@hero.fr>

## Support
For any question or issue, please open a GitHub issue.

---

**Note**: Remember to update the NS records at your domain registrar after applying the Terraform configuration. The redirection won't work until the NS records are properly configured and propagated.
