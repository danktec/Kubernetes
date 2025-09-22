terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.67.0"
    }
  }
}

# This is set in the environment with 'export TF_VAR_DoToken=123'
variable "DoToken" {
  type = string
}
# Your Digital Ocean SSH Key ID "export TF_VAR_DoKey=$(doctl compute ssh-key list | awk '{print $1}' | egrep -v ID)"
# variable "DoKey" {
#   type = string
# }
provider "digitalocean" {
  token = var.DoToken
}

resource "digitalocean_kubernetes_cluster" "dank-test-k8s-sun" {
  name   = "dank-test-k8s-sun"
  region = "sfo3"
  # Grab the latest version slug from `doctl kubernetes options versions` (e.g. "1.14.6-do.1"
  # If set to "latest", latest published version will be used.
  version = "1.33.1-do.3"


  # `doctl compute size list`
  # minimum worker size = s-1vcpu-2gb
  node_pool {
    name       = "worker-pool"
    size       = "s-1vcpu-2gb"
    node_count = 2

    # taint {
    #   key    = "workloadKind"
    #   value  = "database"
    #   effect = "NoSchedule"
    # }
  }
}