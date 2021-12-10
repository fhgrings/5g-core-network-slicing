# Infra PorVir5GC

### [Installations](#Steps)

### [Problems](#Problems)

### [FAQS](#FAQS)

## Installs

### Techs

Proxmox

Terraform

Kubernetes

Ansible

### Install Proxmox

Install Proxmox's ISO to baremetal (https://www.proxmox.com/en/proxmox-ve/get-started)

### Install Terraform

Access SSH

```bash
sudo -i
apt-get install -y software-properties-common

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install -y terraform cloud-init
```

#### Determine Auth Mode

You have two options here:

1. Username/password – you can use the existing default root user and root password here to make things easy… or
2. API keys – this involves setting up a new user, giving that new user the  required permissions, and then setting up API keys so that user doesn’t  have to type in a password to perform actions

I went with the API key method since it is not desirable to have your root password sitting in Terraform files (even as an environment  variable isn’t a great idea). I didn’t really know what I was doing and I basically gave the new user full admin permissions anyways. Should I  lock it down? Surely. Do I know what the minimum required permissions  are to do so? Nope. If someone in the comments or on Reddit could  enlighten me, I’d really appreciate it!

So we need to create a new user. We’ll name it ‘blog_example’. To add a new user go to Datacenter in the left tab, then Permissions ->  Users -> Click add, name the user and click add.

```bash
pveum user add terraform@pam
pveum user token add terraform@pam terraform_token_id --privsep 0
pveum acl modify / -user terraform@pam -role PVEVMAdmin
pveum acl modify /storage/local-lvm -user terraform@pam -role Administrator
```

##### Get token pass again run

```bash
cat /etc/pve/priv/token.cfg | grep "terraform" | cut -d " " -f 2
```



#### Proxmox Terraform provider Install

Create Proxmox Template from Cloud init

```bash
# Download image
wget https://cloud-images.ubuntu.com/focal/20211110/focal-server-cloudimg-amd64.img

# Create the instance
qm create 9000 -name "ubuntu-2004-template" -memory 1024 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1

# Import the OpenStack disk image to Proxmox storage
qm importdisk 9000 focal-server-cloudimg-amd64.img local-lvm

qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0 # Attach the disk to the virtual machine
qm set 9000 --boot c --bootdisk scsi0 # Set the bootdisk to the imported Openstack disk
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --serial0 socket --vga serial0 # Add a serial output
qm set 9000 --agent enabled=1,fstrim_cloned_disks=1 # Enable the Qemu agent
qm template 9000
```

#### Tests  cloned VM's

```bash
echo "Set Machine IP (192.168.100.53/24): "
read vm_ip
qm clone 9000 999 --name test-clone-cloud-init
qm set 999 --sshkey ~/.ssh/id_rsa.pub
qm set 999 --ipconfig0 ip=$vm_ip,gw=$(echo $vm_ip | cut -d '.' -f1-3 | sed 's/$/.1/')

qm start 999
```



```bash
ssh ubuntu@${vm_ip/\/*/}
sudo apt install apache2
curl localhost
exit
```



```bash
qm stop 999 && qm destroy 999
rm focal-server-cloudimg-amd64.img
```



Promox has it's own provider. It's just describe on main.tf that terraform does everthing.

```bash
cd ~
mkdir terraform && cd terraform
touch main.tf vars.tf
```



```bash
cat <<\EOF > main.tf
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
resource "proxmox_vm_qemu" "kube-agent" {
    count = 1 
    name = "test-vm-${count.index + 1}" 
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
    # if you want two NICs, just copy this whole network section and duplicate it
    network {
        model = "virtio"
        bridge = "vmbr0"
    }
	# not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
	lifecycle {
        ignore_changes = [
        	network,
        ]
    }
    # the ${count.index + 1} thing appends text to the end of the ip address
    # in this case, since we are only adding a single VM, the IP will
    # be 10.98.1.91 since count.index starts at 0. this is how you can create
    # multiple VMs and have an IP assigned to each (.91, .92, .93, etc.)
    ipconfig0 = "ip=${var.ip_mask},gw=${var.gw}"
	sshkeys = "${var.ssh_key}"
}
EOF
```

default = "${vm_ip/\/*/}"

​    default = "$(echo $vm_ip | cut -d '.' -f1-3 | sed 's/$/.1/')"

```bash
cat <<EOF > vars.tf
variable "ssh_key" {
  default = "$(cat ~/.ssh/id_rsa.pub)"
}
variable "proxmox_host" {
    default = "$(ls /etc/pve/nodes)"
}
variable "template_name" {
    default = "ubuntu-2004-template"
}
variable "vm_ip" {
    default = "192.168.100.55"
}
variable "ip_mask" {
    default = "192.168.100.55/24"
}
variable "gw" {
    default = "192.168.100.1"
}
variable "provider_ip" {
    default = "$(hostname -i)"
}
variable "token_secret" {
    default = "$(cat /etc/pve/priv/token.cfg | grep "terraform" | cut -d " " -f 2)"
}
EOF
```

#### Terraform Init plan apply

```
terraform init
terraform plan 
terraform apply
```

## FAQS

Instalação do Cloud Init

Muito cuidade ao instalar o cloud init.

Deve ser só instalado nas VM's. Nunca no host proxmox.

Ele desconfigura os arquivos principais de locallização do Proxmox

https://forum.proxmox.com/threads/after-using-cloud-init-the-first-time-pve-is-messed-up-now-lxc-etc-not-working.61970/

Como arrumar?

```bash
sudo apt-get purge --auto-remove cloud-guest-utils cloud-init

$HOSTNAME > /etc/hostname

cat <<EOF > /etc/hosts
127.0.0.1 localhost
$IP proxmox.localhost.com $HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF
```

```bash
Talvez precise alterar as interfaces de rede.
```

```bash
systemctl restart pve-cluster pveproxy pvedaemon
```

