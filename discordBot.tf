# Create service account to run service with no permissions
# resource "google_service_account" "discord" {
#  account_id   = "discord-service-account"
#  display_name = "Discord Service Account"
# }

resource "google_compute_network" "discord" {
 name = "discord"
}

#Open the firewall for Minecraft traffic
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.discord.name
  # ICMP (ping)
  allow {
    protocol = "icmp"
  }
  # SSH
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["discord"]
}


resource "google_compute_instance" "discord-bot" {
  depends_on = [ null_resource.build_docker_image, data.local_file.start_script ]
  name         = "discord-bot"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["discord"]
  allow_stopping_for_update = true

  metadata = {
    google-logging-enabled    = "true"
  }

  metadata_startup_script = data.local_file.start_script.content

  shielded_instance_config {
    enable_integrity_monitoring = "true"
    enable_secure_boot          = "false"
    enable_vtpm                 = "true"
  }
      
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.discord.name
    access_config {
    }
  }

  # labels = {
  #   container-vm = module.gce-container-discord-bot.vm_container_label
  # }

  scheduling {
    preemptible         = false # Closes within 24 hours (sometimes sooner)
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    #email  = "default"
    #email  = google_service_account.discord.email
    scopes = [
      "compute-rw",
      "logging-write",
      "service-control",
      "service-management",
      "storage-ro",
      "monitoring-write"
      ]
  }
}