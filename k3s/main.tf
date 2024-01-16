terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
# This is set in the environment with 'export TF_VAR_DoToken=123'
variable "DoToken" {
  type = string
}
# Your Digital Ocean SSH Key ID "export TF_VAR_DoKey=$(doctl compute ssh-key list | awk '{print $1}' | egrep -v ID)"
variable "DoKey" {
  type = string
}
provider "digitalocean" {
  token = var.DoToken
}

# Controller
resource "digitalocean_droplet" "k3sController" {
  image     = "debian-12-x64" # doctl compute image list-distribution
  name      = "debian12-k3sController"
  region    = "sfo3"
  ipv6      =  false
  size      = "s-2vcpu-2gb" # doctl compute size list | awk '{print $1}'
  ssh_keys  = [var.DoKey]
  tags      = ["name:k3sController"]
  user_data = file("setup.sh")
}
output "k3sController" {
  value = digitalocean_droplet.k3sController[*].ipv4_address
}

# Worker
resource "digitalocean_droplet" "k3sWorker" {
  count     = 1
  image     = "debian-12-x64" # doctl compute image list-distribution
  name      = "debian12-k3sWorker"
  region    = "sfo3"
  ipv6      =  false
  size      = "s-1vcpu-1gb" # doctl compute size list | awk '{print $1}'
  ssh_keys  = [var.DoKey]
  tags      = ["name:k3sWorker"]
  user_data = file("setup.sh")
}
output "k3sWorker" {
  value = digitalocean_droplet.k3sWorker[*].ipv4_address
}

