variable "ssh_key" {
  default = "$(cat ~/.ssh/id_rsa.pub)"
}
variable "proxmox_host" {
    default = "$(ls /etc/pve/nodes)"
}
variable "template_name" {
    default = "ubuntu-2004-template"
}
variable "provider_ip" {
    default = "$(hostname -i)"
}
variable "token_secret" {
    default = "$(cat /etc/pve/priv/token.cfg | grep 'terraform' | cut -d ' ' -f 2)"
}
