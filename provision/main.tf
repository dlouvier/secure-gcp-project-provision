variable "billing_account" {}
variable "project_admin_name" {}

locals {
  projects = {
    "app-one" = {
      "gh_repo"       = "dlouvier/secure-project-provision"
      "activate_apis" = []
    }
  }
}


# This module provision the "admin" project which holds
# the Workload Identity Pools and the terraform states
module "project_admin" {
  source = "./modules/project_admin"

  billing_account    = var.billing_account
  project_admin_name = var.project_admin_name
}


# These part provision each app projects based in the configuration in "locals.projects"
module "project_app" {
  source   = "./modules/project_app"
  for_each = local.projects

  activate_apis   = each.value.activate_apis
  billing_account = var.billing_account

  project_admin_name = module.project_admin.project_admin_name
  project_app_name   = "${each.key}-${module.project_admin.project_suffix}"

  gh_oidc_pool_name = module.project_admin.gh_oidc_pool_name
  gh_repo           = each.value.gh_repo
}
