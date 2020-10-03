

# Provider Config

provider "aci" {
  username = var.username
  password = var.password
  url      = var.url
  insecure = true

}

#Tenant + AWS Account + VRF

resource "aci_tenant" "terraform_ten" {
  name = var.tenant_name
}

resource "aci_cloud_aws_provider" "cloud_apic_provider" {
  tenant_dn         = aci_tenant.terraform_ten.id
  account_id        = var.account_id
  is_trusted        = "yes"
}

resource "aci_vrf" "vrf1" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = "vrf-1"
}

#Cloud Context Profile + Subnets

resource "aci_cloud_context_profile" "ctx-vrf1-useast1" {
  tenant_dn                = aci_tenant.terraform_ten.id
  name                     = "ctx-vrf1-useast1"
  primary_cidr             = "172.11.0.0/16"
  region                   = "us-east-1"
  cloud_vendor             = "aws"
  relation_cloud_rs_to_ctx = aci_vrf.vrf1.id
}

resource "aci_cloud_cidr_pool" "cloud_cidr_pool" {
    cloud_context_profile_dn = aci_cloud_context_profile.ctx-vrf1-useast1.id
    addr                     = "172.11.0.0/16"

}

resource "aci_cloud_subnet" "cloud_subnet" {
  cloud_cidr_pool_dn            = aci_cloud_cidr_pool.cloud_cidr_pool.id
  ip                            = "172.11.1.0/24"
  zone                          = "us-east-1a"

}
#Define Application Profile

resource "aci_cloud_applicationcontainer" "myapp" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = "myapp"
}

#Define Web EPG

resource "aci_cloud_epg" "cloud_apic_web" {
  name                             = "Web"
  cloud_applicationcontainer_dn    = aci_cloud_applicationcontainer.myapp.id
  relation_fv_rs_cons              = [aci_contract.contract_epg1_epg2.id]
  relation_fv_rs_prov              = [aci_contract.contract_web_internet.id]
  relation_cloud_rs_cloud_epg_ctx  = aci_vrf.vrf1.id
}

resource "aci_cloud_endpoint_selector" "cloud_ep_selector1" {
  cloud_epg_dn    = aci_cloud_epg.cloud_apic_web.id
  name             = "ep1-select"
  match_expression = "custom:epg=='web'"
}

#Define DB EPG

resource "aci_cloud_epg" "cloud_apic_db" {
  name                             = "DB"
  cloud_applicationcontainer_dn    = aci_cloud_applicationcontainer.myapp.id
  relation_fv_rs_prov              = [aci_contract.contract_epg1_epg2.id]
  relation_cloud_rs_cloud_epg_ctx  = aci_vrf.vrf1.id
}

resource "aci_cloud_endpoint_selector" "cloud_ep_selector2" {
  cloud_epg_dn     = aci_cloud_epg.cloud_apic_db.id
  name             = "ep2-select"
  match_expression = "custom:epg=='db'"
}

#Define Web to DB Contract + Filter + Subject

resource "aci_contract" "contract_epg1_epg2" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = "web-to-db"
}

resource "aci_filter" "web-to-db" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = "web-to-db"
}

resource "aci_filter_entry" "ssh" {
  name        = "ssh"
  filter_dn   = aci_filter.web-to-db.id
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "22"
  d_to_port   = "22"
}

resource "aci_filter_entry" "icmp" {
  name      = "icmp"
  filter_dn = aci_filter.web-to-db.id
  ether_t   = "ip"
  prot      = "icmp"
}

resource "aci_contract_subject" "web-to-db" {
  contract_dn                  = aci_contract.contract_epg1_epg2.id
  name                         = "Subject"
  relation_vz_rs_subj_filt_att = [aci_filter.web-to-db.id]
}

#Define Web to Internet Contract + Filter + Subject

resource "aci_contract" "contract_web_internet" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = "internet-access"
}

resource "aci_filter" "internet" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = "internet"
}

resource "aci_filter_entry" "all" {
  name      = "all"
  filter_dn = aci_filter.internet.id
  ether_t   = "unspecified"
}

resource "aci_contract_subject" "web-internet" {
  contract_dn                  = aci_contract.contract_web_internet.id
  name                         = "Subject"
  relation_vz_rs_subj_filt_att = [aci_filter.internet.id]
}

#Define Cloud External EPG for Internet Access (L3Out)

resource "aci_cloud_external_epg" "cloud_apic_ext_epg" {
  name                             = "Internet"
  cloud_applicationcontainer_dn    = aci_cloud_applicationcontainer.myapp.id
  relation_fv_rs_cons              = [aci_contract.contract_web_internet.id]
  relation_cloud_rs_cloud_epg_ctx  = aci_vrf.vrf1.id
}

resource "aci_cloud_endpoint_selectorfor_external_epgs" "ext_ep_selector" {
  cloud_external_epg_dn  = aci_cloud_external_epg.cloud_apic_ext_epg.id
  name                   = "Internet"
  subnet                 = "0.0.0.0/0"
}
