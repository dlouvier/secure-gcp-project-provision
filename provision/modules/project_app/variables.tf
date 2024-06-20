variable "activate_apis" {
  type = list(string)
}

variable "billing_account" {
  type = string
}

variable "gh_oidc_pool_name" {
  type = string
}

variable "gh_repo" {
  type = string
}

variable "project_admin_name" {
  type = string
}

variable "project_app_name" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-central2"
}



