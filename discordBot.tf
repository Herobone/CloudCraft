resource "google_compute_instance" "discord-bot" {
  depends_on = [ local_file.startup_script ]
  name         = "discord-bot"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags         = ["discord"]

  metadata_startup_script = "/var/bot/start.sh;"

  metadata = {
    enable-oslogin = "TRUE"
  }
      
  boot_disk {
    auto_delete = true # Keep disk after shutdown (game data)
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.minecraft.name
    access_config {
    }
  }

  scheduling {
    preemptible       = false # Closes within 24 hours (sometimes sooner)
    automatic_restart = true
  }

  provisioner "file" {
    source = "tmp/bot"
    destination = "/var"
  }
}