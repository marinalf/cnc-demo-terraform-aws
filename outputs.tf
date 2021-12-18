# Outputs for EC2 deployment

output "vpc" {
  value = "context-[${aci_vrf.vrf1.name}]-addr-[${aci_cloud_context_profile.ctx-vrf1.primary_cidr}]"
}

output "subnet" {
  value = aci_cloud_subnet.cloud_subnet_user["web-subnet"].ip
}
