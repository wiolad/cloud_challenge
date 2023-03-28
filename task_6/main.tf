provider "google" {
  project = "weighty-replica-378016"
  region  = "europe-central2"
  zone    = "europe-central2-c"
}

resource "google_storage_bucket" "static" {
 project       = "weighty-replica-378016"
 name          = "bucket-tf-wd-test"
 location      = "europe-central2"
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

resource "google_storage_bucket_access_control" "public_rule" {
  bucket = "bucket-tf-wd-test"
  role   = "READER"
  entity = "allUsers"
}

resource "google_compute_instance" "dare-id-vm" {
  name         = "dareit-vm-tf"
  machine_type = "e2-medium"
  zone         = "europe-central2-c"

  tags = ["dareit"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        managed_by_terraform = "true"
      }
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}

// POSTGRESQL INSTANCE
resource "google_sql_database_instance" "dareit" {
  database_version = "POSTGRES_9_6"
  region = "europe-central2"

  settings {
      tier = "db-f1-micro"
      ip_configuration {
          ipv4_enabled = true
      }
  }
}

resource "google_sql_user" "user" {
  name     = "dareit_user"
  instance = "${google_sql_database_instance.dareit.name}"
  password = "test123"
}
