output "project_suffix" {
  value = local.suffix
}

output "project_admin_name" {
  value = module.project_admin.project_id
}

output "gh_oidc_pool_name" {
  value = module.gh_oidc.pool_name
}
