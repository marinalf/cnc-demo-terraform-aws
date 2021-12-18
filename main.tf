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
  tenant_dn  = aci_tenant.terraform_ten.id
  account_id = var.account_id
  is_trusted = "yes"
}

resource "aci_vrf" "vrf1" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = var.vrf_name
}

#Cloud Context Profile (VPC) + Subnets

resource "aci_cloud_context_profile" "ctx-vrf1" {
  tenant_dn                = aci_tenant.terraform_ten.id
  name                     = var.cxt_name
  primary_cidr             = var.cxt_cidr
  region                   = var.cxt_region
  cloud_vendor             = var.cloud_vendor
  relation_cloud_rs_to_ctx = aci_vrf.vrf1.id
  hub_network              = "uni/tn-infra/gwrouterp-${var.hub_name}"
}

data "aci_cloud_cidr_pool" "cloud_cidr_pool" {
  cloud_context_profile_dn = aci_cloud_context_profile.ctx-vrf1.id
  addr                     = var.cxt_cidr
}

#User & TGW Subnets

resource "aci_cloud_subnet" "cloud_subnet_tgw" {
  for_each           = var.tgw_subnets
  cloud_cidr_pool_dn = data.aci_cloud_cidr_pool.cloud_cidr_pool.id
  name               = each.value.name
  ip                 = each.value.ip
  usage              = each.value.usage
  zone               = "uni/clouddomp/provp-aws/${each.value.zone}"
}

resource "aci_cloud_subnet" "cloud_subnet_user" {
  for_each           = var.user_subnets
  cloud_cidr_pool_dn = data.aci_cloud_cidr_pool.cloud_cidr_pool.id
  name               = each.value.name
  ip                 = each.value.ip
  usage              = each.value.usage
  zone               = "uni/clouddomp/provp-aws/${each.value.zone}"
  depends_on         = [aci_cloud_subnet.cloud_subnet_tgw]
}

#Define Application Profile

resource "aci_cloud_applicationcontainer" "myapp" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = var.app_profile
}

#Define Web EPG

resource "aci_cloud_epg" "cloud_apic_web" {
  name                            = var.epg_web
  cloud_applicationcontainer_dn   = aci_cloud_applicationcontainer.myapp.id
  relation_fv_rs_cons             = [aci_contract.web-to-db.id]
  relation_fv_rs_prov             = [aci_contract.web_internet.id]
  relation_cloud_rs_cloud_epg_ctx = aci_vrf.vrf1.id
}

resource "aci_cloud_endpoint_selector" "cloud_ep_selector1" {
  cloud_epg_dn     = aci_cloud_epg.cloud_apic_web.id
  name             = var.selector_web
  match_expression = "custom:epg=='web'"
}

#Define DB EPG

resource "aci_cloud_epg" "cloud_apic_db" {
  name                            = var.epg_db
  cloud_applicationcontainer_dn   = aci_cloud_applicationcontainer.myapp.id
  relation_fv_rs_prov             = [aci_contract.web-to-db.id]
  relation_cloud_rs_cloud_epg_ctx = aci_vrf.vrf1.id
}

resource "aci_cloud_endpoint_selector" "cloud_ep_selector2" {
  cloud_epg_dn     = aci_cloud_epg.cloud_apic_db.id
  name             = var.selector_db
  match_expression = "IP=='172.11.4.0/24'"
}

#Define Web to DB Contract + Filter + Subject

resource "aci_contract" "web-to-db" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = var.contract_name
}

resource "aci_filter" "web-to-db" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = var.filter_name
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
  contract_dn                  = aci_contract.web-to-db.id
  name                         = "subject1"
  relation_vz_rs_subj_filt_att = [aci_filter.web-to-db.id]
}

#Define Cloud External EPG for Internet Access (L3Out)

resource "aci_cloud_external_epg" "cloud_apic_ext_epg" {
  name                            = var.epg_internet
  cloud_applicationcontainer_dn   = aci_cloud_applicationcontainer.myapp.id
  relation_fv_rs_cons             = [aci_contract.web_internet.id]
  relation_cloud_rs_cloud_epg_ctx = aci_vrf.vrf1.id
  route_reachability              = "internet"
}

resource "aci_cloud_endpoint_selectorfor_external_epgs" "ext_ep_selector" {
  cloud_external_epg_dn = aci_cloud_external_epg.cloud_apic_ext_epg.id
  name                  = var.selector_internet
  subnet                = var.subnet_internet
}

#Define Web to Internet Contract + Filter + Subject

resource "aci_contract" "web_internet" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = var.contract_name_internet
}

resource "aci_filter" "internet" {
  tenant_dn = aci_tenant.terraform_ten.id
  name      = var.filter_name_internet
}

resource "aci_filter_entry" "all" {
  name      = "all"
  filter_dn = aci_filter.internet.id
  ether_t   = "unspecified"
}

resource "aci_contract_subject" "web_internet" {
  contract_dn                  = aci_contract.web_internet.id
  name                         = "subject2"
  relation_vz_rs_subj_filt_att = [aci_filter.internet.id]
}
