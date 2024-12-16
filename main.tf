provider "google" {
  credentials = file("advance-engine-444818-p0-cfbcd582bdbf.json") # 서비스 계정 키 파일 경로
  project     = "advance-engine-444818-p0"                        # GCP 프로젝트 ID
  region      = "asia-northeast3"                                # 리전
}

# GKE Kubernetes 클러스터 생성
resource "google_container_cluster" "gke_cluster" {
  name               = "k8s-cluster"
  location           = var.region
  initial_node_count = 3

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Cloud SQL 인스턴스 생성
resource "google_sql_database_instance" "mysql_instance" {
  name = "mysql-instance"
  region = var.region

  settings {
    tier = "db-f1-micro" # 최소 사양
    availability_type = "ZONAL"
  }
}

# Cloud SQL 데이터베이스 생성
resource "google_sql_database" "db" {
  name     = "mydatabase"
  instance = google_sql_database_instance.mysql_instance.name
}

# Cloud SQL 사용자 생성
resource "google_sql_user" "user" {
  name     = "api_user"
  instance = google_sql_database_instance.mysql_instance.name
  password = "password123"
}

# GKE 클러스터 인증 정보 출력
output "gke_cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "gke_cluster_ca_certificate" {
  value = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
}

# Cloud SQL 정보 출력
output "cloud_sql_instance_connection_name" {
  value = google_sql_database_instance.mysql_instance.connection_name
}

output "cloud_sql_user" {
  value = google_sql_user.user.name
}

output "cloud_sql_database_name" {
  value = google_sql_database.db.name
}
