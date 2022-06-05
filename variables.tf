
#Cloud APIC Credentials & AWS Acccount

variable "username" {}
variable "password" {}
variable "url" {}
variable "account_id" {}

# AWS Hub Network

variable "hub_name" {
  description = "Replace with hub network name defined during the first time setup"
  default = "TGW"
}

# Tenant + VRF

variable "tenant_name" {
  default = "demo"
}

variable "vrf_name" {
  default = "vrf-1"
}

#Cloud Context Profile (VPC) + Subnets

variable "cxt_name" {
  default = "ctx-vrf1-useast1"
}

variable "cxt_cidr" {
  default = "172.11.0.0/16"
}

variable "cxt_region" {
  default = "us-east-1"
}

variable "cloud_vendor" {
  default = "aws"
}

variable "tgw_subnets" {
  type = map(object({
    name  = string
    ip    = string
    usage = string
    zone  = string
  }))
  default = {
    tgw-a-subnet = {
      name  = "tgw-a-subnet"
      ip    = "172.11.1.0/24"
      usage = "gateway"
      zone  = "region-us-east-1/zone-us-east-1a"
    },
    tgw-b-subnet = {
      name  = "tgw-b-subnet"
      ip    = "172.11.2.0/24"
      usage = "gateway"
      zone  = "region-us-east-1/zone-us-east-1b"
    }
  }
}

variable "user_subnets" {
  type = map(object({
    name  = string
    ip    = string
    usage = string
    zone  = string
  }))
  default = {
    web-subnet = {
      name  = "web-subnet"
      ip    = "172.11.3.0/24"
      usage = "user"
      zone  = "region-us-east-1/zone-us-east-1a"
    },
    db-subnet = {
      name  = "db-subnet"
      ip    = "172.11.4.0/24"
      usage = "user"
      zone  = "region-us-east-1/zone-us-east-1b"
    }
  }
}


# EPGs + Contract + Filter

variable "app_profile" {
  default = "MyApp"
}

variable "epg_web" {
  default = "Web"
}

variable "epg_db" {
  default = "DB"
}

variable "selector_web" {
  default = "Web"
}

variable "selector_db" {
  default = "DB"
}

variable "contract_name" {
  default = "web-to-db"
}

variable "filter_name" {
  default = "web-to-db"
}

# Internet External EPG + Contract + Filter

variable "epg_internet" {
  default = "Internet"
}

variable "selector_internet" {
  default = "Internet"
}

variable "subnet_internet" {
  default = "0.0.0.0/0"
}

variable "contract_name_internet" {
  default = "internet-access"
}

variable "filter_name_internet" {
  default = "internet-access"
}
