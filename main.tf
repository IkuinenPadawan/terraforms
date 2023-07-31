terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.7.4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.1.100:8006/api2/json"
  pm_api_token_id = var.token_id
  pm_api_token_secret = var.token_secret 
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "linux-sandbox" {
  count = 2
  name = "linux-vm-${count.index}"

  target_node = var.proxmox_host

  clone = var.template_name

  agent = 1
  os_type = "cloud-init"
  cores = 1
  sockets = 1
  cpu = "host"
  memory = 1024
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = "32G"
    type = "scsi"
    storage = "local-lvm"
    iothread = 1
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=192.168.1.8${count.index}/24,gw=192.168.1.1"

}

resource "proxmox_lxc" "lxc" {
  count = 1
  target_node = var.proxmox_host

  cores = 1
  memory = 512
  hostname = "container-${count.index}"
  password = "rootroot"

  network  {
    name = "eth0"
    bridge = "vmbr0"
    ip = "dhcp"
  }
  start = true # start after creation

  # using ubuntu container template
  ostemplate = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  rootfs {
    storage = "local-lvm"
    size = "4G"
  }
}
