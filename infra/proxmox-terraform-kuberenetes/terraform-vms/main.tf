terraform {
      required_providers {
        proxmox = {
          source = "telmate/proxmox"
          version = "2.7.4"
        }
        }
}
provider "proxmox" {
    pm_api_url = "https://${var.provider_ip}:8006/api2/json"
    pm_api_token_id = "terraform@pam!terraform_token_id"
    pm_api_token_secret = "${var.token_secret}"
    pm_tls_insecure = true
}
resource "proxmox_vm_qemu" "kube-master" {
    count = 1 
    name = "kube-master" 
    target_node = var.proxmox_host
    clone = var.template_name
    agent = 1
    os_type = "cloud-init"
    cores = 2
    sockets = 1
    cpu = "host"
    memory = 2048
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    disk {
        slot = 0
        size = "10G"
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
    ipconfig0 = "ip=192.168.100.4${count.index + 1}/24,gw=192.168.100.1"
        sshkeys = "${var.ssh_key}"
}
resource "proxmox_vm_qemu" "kube-node" {
    count = 3 
    name = "kube-node-${count.index + 1}" 
    target_node = var.proxmox_host
    clone = var.template_name
    agent = 1
    os_type = "cloud-init"
    cores = 2
    sockets = 1
    cpu = "host"
    memory = 2048
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"
    disk {
        slot = 0
        size = "10G"
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
    ipconfig0 = "ip=192.168.100.6${count.index + 1}/24,gw=192.168.100.1"
        sshkeys = "${var.ssh_key}"
}
