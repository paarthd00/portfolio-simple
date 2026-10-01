terraform {
  required_version = ">= 1.5"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# Authenticates with the CLOUDFLARE_API_TOKEN environment variable.
provider "cloudflare" {}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID that will host the site."
  type        = string
}

variable "domain" {
  description = "Domain to serve the site on. Must be an active zone in the same Cloudflare account."
  type        = string
  default     = "pdamnme.com"
}

variable "cloudflare_zone_id" {
  description = "Zone ID of the domain (from the zone overview page, right sidebar)."
  type        = string
}

# Uploads everything in ./site as static assets served from the edge.
# Re-run `terraform apply` after changing files in ./site to deploy.
resource "cloudflare_workers_script" "portfolio" {
  account_id  = var.cloudflare_account_id
  script_name = "portfolio-simple"

  compatibility_date = "2026-09-30"

  assets = {
    directory = "${path.module}/site"
    config = {
      html_handling = "auto-trailing-slash"
    }
  }
}

resource "cloudflare_workers_custom_domain" "apex" {
  account_id = var.cloudflare_account_id
  hostname   = var.domain
  service    = cloudflare_workers_script.portfolio.script_name
  zone_id    = var.cloudflare_zone_id
}

resource "cloudflare_workers_custom_domain" "www" {
  account_id = var.cloudflare_account_id
  hostname   = "www.${var.domain}"
  service    = cloudflare_workers_script.portfolio.script_name
  zone_id    = var.cloudflare_zone_id
}

# Redirect all plain-HTTP traffic to HTTPS at the edge.
resource "cloudflare_zone_setting" "always_use_https" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "always_use_https"
  value      = "on"
}
