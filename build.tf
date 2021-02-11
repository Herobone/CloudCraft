# Hydrate docker template file into .build directory
resource "local_file" "startup_script" {
    depends_on = [ null_resource.prepare_bot ]
  content = templatefile("${path.module}/start.sh.template", {
    vm_name = google_compute_instance.minecraft.name
    discord_token   = var.discord_token
  })
  filename = "${path.module}/tmp/bot/start.sh"
}

resource "null_resource" "prepare_bot" {
  provisioner "local-exec" {
    command = "mkdir -p tmp/bot; cp servertools/package.json tmp/bot; cp -r servertools/src tmp/bot/src;"
  }
}