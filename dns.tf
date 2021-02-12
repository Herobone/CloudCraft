provider "cloudflare" {
  api_token = var.cloud_flare_api_token
}

data "google_compute_instance" "minecraft" {
  name = google_compute_instance.minecraft.name
  zone = var.zone
}

resource "cloudflare_record" "mc" {
  depends_on = [google_compute_instance.minecraft]
  zone_id = var.cloudflare_zone_id
  name    = "mc"
  value   = data.google_compute_instance.minecraft.network_interface.0.access_config.0.nat_ip
  type    = "A"
  proxied = false
}