module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "15.0.1"

  name              = var.project_app_name
  random_project_id = false

  activate_apis = var.activate_apis

  billing_account = var.billing_account

  bucket_force_destroy = true # this is only for the demo, so it can be easily destroy the provisioned resources
  bucket_location      = var.region
  bucket_name          = "${var.project_app_name}-terraform"
  bucket_pap           = "enforced"
  bucket_project       = var.project_admin_name
  bucket_ula           = true # needed for the be able to authentificate via OIDC
  bucket_versioning    = true

  create_project_sa = false
}

# Provides "Viewer" role access when the workflow runs from a pull requests (needed to run the plan)
resource "google_project_iam_member" "gh_viewer_access" {
  project = var.project_app_name
  role    = "roles/viewer"
  member  = "principal://iam.googleapis.com/${var.gh_oidc_pool_name}/subject/repo:${var.gh_repo}:pull_request"
}

# Provides "Editor" role access when the workflow runs from a pull requests (needed to run the plan)
resource "google_project_iam_member" "gh_editor_access" {
  project = var.project_app_name
  role    = "roles/editor"
  member  = "principal://iam.googleapis.com/${var.gh_oidc_pool_name}/subject/repo:${var.gh_repo}:ref:refs/heads/main"
}

# In addition we need to add as Bucket/Object Viewer and Owner to the state bucket
# so the GitHub job can read and modify the state
resource "google_storage_bucket_iam_member" "bucket_reader" {
  bucket = "app-one-r9pi-terraform"
  role   = "roles/storage.legacyBucketReader"
  member = "principal://iam.googleapis.com/${var.gh_oidc_pool_name}/subject/repo:${var.gh_repo}:pull_request"
}

resource "google_storage_bucket_iam_member" "object_reader" {
  bucket = "app-one-r9pi-terraform"
  role   = "roles/storage.legacyBucketReader"
  member = "principal://iam.googleapis.com/${var.gh_oidc_pool_name}/subject/repo:${var.gh_repo}:pull_request"
}

resource "google_storage_bucket_iam_member" "bucket_writer" {
  bucket = "app-one-r9pi-terraform"
  role   = "roles/storage.legacyBucketReader"
  member = "principal://iam.googleapis.com/${var.gh_oidc_pool_name}/subject/repo:${var.gh_repo}:ref:refs/heads/main"
}

resource "google_storage_bucket_iam_member" "object_writer" {
  bucket = "app-one-r9pi-terraform"
  role   = "roles/storage.legacyBucketReader"
  member = "principal://iam.googleapis.com/${var.gh_oidc_pool_name}/subject/repo:${var.gh_repo}:ref:refs/heads/main"
}
