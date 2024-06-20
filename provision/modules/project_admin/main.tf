locals {
  suffix = random_string.suffix.id
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  lower   = true
  upper   = false
}

# This module provision the "admin" project which holds
# the Workload Identity Pools and the terraform states
module "project_admin" {
  source  = "terraform-google-modules/project-factory/google"
  version = "15.0.1"

  name              = "${var.project_admin_name}-${local.suffix}"
  random_project_id = false

  activate_apis = ["iam.googleapis.com"]

  billing_account = var.billing_account

  bucket_force_destroy = true # this is only for the demo, so it can be easily destroy the provisioned resources
  bucket_location      = var.region
  bucket_name          = "${var.project_admin_name}-${local.suffix}-terraform"
  bucket_pap           = "enforced"
  bucket_project       = "${var.project_admin_name}-${local.suffix}"
  bucket_ula           = true # needed for the OIDC Principal used later by Terragrunt
  bucket_versioning    = true

  create_project_sa = false
}

# Provisions the OIDC resources in the "admin" project
module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version     = "3.1.2"
  project_id  = module.project_admin.project_id
  pool_id     = "pool-${local.suffix}"
  provider_id = "gh-provider-${local.suffix}"
}

