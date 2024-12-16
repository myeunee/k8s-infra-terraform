resource "google_sql_database_instance" "mysql_instance" {
  name = "mysql-instance"
  region = "asia-northeast3"

  settings {
    tier = "db-f1-micro" # 최소 사양으로 설정
    availability_type = "ZONAL"
  }
}

resource "google_sql_database" "db" {
  name     = "mydatabase"
  instance = google_sql_database_instance.mysql_instance.name
}

resource "google_sql_user" "user" {
  name     = "api_user"
  instance = google_sql_database_instance.mysql_instance.name
  password = "password" # 비밀번호 설정하기!!!
}
