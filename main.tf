resource "google_project_service" "enabled_services" {
  for_each           = toset(var.gcp_service_list)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_service_account" "default" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"

  depends_on = [google_project_service.enabled_services]
}

resource "google_compute_instance" "vm-terraform" {
  name         = "terraform-instance"
  machine_type = "e2-medium"
  zone         = "asia-south1-a"

  tags = ["http"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"

    # 👇 This line is what assigns the external IP
    access_config {}
  }

  metadata = {
    foo = "bar"
  }

  # The magic happens here:
  metadata_startup_script = file("./startup.sh")


  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}