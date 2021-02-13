# CloudCraft

CloudCraft is a template repository for a whole Minecraft Experience hosted in the Google Cloud!

## Features
 - Discord Bot for showing the state of the Server, as well as starting/stopping it
 - Cheap Preemptible Server
 - Configurable
 - Static/Dynamic IP Support
 - Cloudflare DNS Integration

## CHEATSHEET
### Show startup script log
```bash
sudo journalctl -u google-startup-scripts.service
```

### SSH Connection
```bash
gcloud beta compute ssh --zone "us-east1-b" "discord-bot"
```

### GCP
 - [Scopes for Compute Engine](https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes)
 - [OS Images for Compute Engine](https://cloud.google.com/compute/docs/images/os-details)

### Terraform
 - [Compute Instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)