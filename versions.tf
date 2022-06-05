# Define the provider source

terraform {
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
    }
  }
  required_version = ">= 1.1"
}

# Provider Config

provider "aci" {
  username = var.username
  password = var.password
  url      = var.url
  insecure = true

}
