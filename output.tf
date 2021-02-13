output "minecraft_ip" {
  value = data.google_compute_instance.minecraft.network_interface.0.access_config.0.nat_ip
}
output "container_image_url" {
  value = data.google_container_registry_image.discord-gcp-bot.image_url
}