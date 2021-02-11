variable "project" {
  type    = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-b"
}

variable "network_name" {
  type    = string
  default = "default"
}

variable "cloud_flare_api_token" {
  type    = string
}

variable "cloudflare_zone_id" {
  type    = string
}

variable "discord_token" {
  type    = string
}