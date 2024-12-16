provider "google" {
  credentials = file("advance-engine-444818-p0-cfbcd582bdbf.json") # 서비스 계정 키 파일 경로
  project     = "advance-engine-444818-p0"                        # GCP 프로젝트 ID
  region      = "asia-northeast3"                                 # 리전
}

# GKE 클러스터 생성
resource "google_container_cluster" "gke_cluster" {
  name               = "k8s-cluster"
  location           = var.region
  initial_node_count = 1

  # Default Node Pool 제거
  remove_default_node_pool = true

  # 내부 IP 사용 설정
  ip_allocation_policy {}
  private_cluster_config {
    enable_private_endpoint = false # API 서버는 외부 접근 가능
    enable_private_nodes    = true  # 노드는 내부 IP만 사용
  }

  # 마스터 권한 구성
  master_authorized_networks_config {}
}

# Node Pool 생성
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-nodes"
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 2

  node_config {
    machine_type       = "e2-medium"
    disk_size_gb       = 50
    oauth_scopes       = ["https://www.googleapis.com/auth/cloud-platform"]
    service_account    = "default"
    tags               = ["no-external-ip"]

    # 내부 IP만 사용
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # 보안 부팅 활성화
    shielded_instance_config {
      enable_secure_boot = true
    }

    # 네트워크 태그 추가
    network_tags = ["no-external-ip"]
  }

  # 노드 자동 업그레이드 및 복구 설정
  management {
    auto_upgrade = true
    auto_repair  = true
  }
}

# Cloud SQL 인스턴스 생성
resource "google_sql_database_instance" "mysql_instance" {
  name = "mysql-instance"
  region = var.region
  database_version = "MYSQL_8_0"  # MySQL 버전 명시

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
