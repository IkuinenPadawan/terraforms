variable "proxmox_host" {
  default = "pve"
}

variable "template_name" {
  default = "ubuntu-2204-template"
}

variable "token_id" {
  description = "Token ID for authentication"
}

variable "token_secret" {
  description = "Token secret for authentication"
}
