# Create service account to run service with no permissions
resource "google_service_account" "discord" {
  account_id   = "discord"
  display_name = "discord"
}

module "gce-container-discord-bot" {
  source = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image="gcr.io/google-samples/hello-app:1.0"
    env = [
      {
        VM_NAME = google_compute_instance.minecraft.name
        DISCORD_TOKEN = var.discord_token
      }
    ]
  }

  restart_policy = "Always"
}

resource "google_compute_network" "discord" {
  name = "discord"
}

resource "google_compute_instance" "discord-bot" {
  depends_on = [ local_file.startup_script ]
  name         = "discord-bot"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags         = ["discord"]
  allow_stopping_for_update = true

  metadata_startup_script = "/var/bot/start.sh;"

  metadata = {
    gce-container-declaration = module.gce-container-discord-bot.metadata_value
  }
      
  boot_disk {
    auto_delete = true
    initialize_params {
      image = module.gce-container-discord-bot.source_image
    }
  }

  network_interface {
    network = google_compute_network.discord.name
    access_config {
    }
  }

  labels = {
    container-vm = module.gce-container-discord-bot.vm_container_label
  }

  scheduling {
    preemptible       = false # Closes within 24 hours (sometimes sooner)
    automatic_restart = true
  }

  service_account {
    email  = google_service_account.discord.email
    scopes = ["default", "compute-rw"]
  }
}