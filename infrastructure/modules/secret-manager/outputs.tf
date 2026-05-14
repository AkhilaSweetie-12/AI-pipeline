output "secret_ids" {
  description = "Secret IDs"
  value = {
    for key, secret in google_secret_manager_secret.secrets :
    key => secret.id
  }
  sensitive = true
}

output "secret_names" {
  description = "Secret names"
  value = {
    for key, secret in google_secret_manager_secret.secrets :
    key => secret.secret_id
  }
}

output "secret_versions" {
  description = "Secret version IDs"
  value = {
    for key, version in google_secret_manager_secret_version.secret_versions :
    key => version.id
  }
  sensitive = true
}
