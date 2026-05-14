output "instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.main.name
}

output "instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.main.connection_name
}

output "database_name" {
  description = "Database name"
  value       = google_sql_database.database.name
}

output "public_ip_address" {
  description = "Public IP address"
  value       = google_sql_database_instance.main.public_ip_address
  sensitive   = true
}

output "private_ip_address" {
  description = "Private IP address"
  value       = google_sql_database_instance.main.private_ip_address
  sensitive   = true
}

output "database_username" {
  description = "Database username"
  value       = google_sql_user.app_user.name
}
