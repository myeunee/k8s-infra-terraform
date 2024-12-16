output "gke_cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "cloud_sql_instance_name" {
  value = google_sql_database_instance.mysql_instance.name
}

output "cloud_sql_connection_name" {
  value = google_sql_database_instance.mysql_instance.connection_name
}
