# Hydrate docker template file into .build directory

data "google_container_registry_image" "discord-gcp-bot" {
  name = "discord-gcp-bot"
  region = "eu"
}

resource "local_file" "startup_script" {
  content = templatefile("${path.module}/build.sh.template", {
    container-image-name = data.google_container_registry_image.discord-gcp-bot.image_url
  })
  filename = "${path.module}/tmp/bot/build.sh"
}

resource "null_resource" "build_docker_image" {
  depends_on = [ local_file.startup_script ]
  provisioner "local-exec" {
    command = "./tmp/bot/build.sh"
  }
}