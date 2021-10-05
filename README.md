

# Sample [terraform](https://www.terraform.io) integration with [Cisco Cloud ACI](https://www.cisco.com/c/en/us/solutions/data-center-virtualization/application-centric-infrastructure/cloud-aci.html)

This project shows how Cloud ACI works on public clouds such as AWS, how it normalizes and translates the ACI policy model into public cloud native constructs, and how Terraform can be leveraged to automate Cloud ACI operations.

**High Level Diagram**

<img width="600" alt="aws" src="https://github.com/marinalf/cloudaci-demo-terraform-aws/blob/main/images/hld.png">

## Use Case: Single Region/Tenant/VRF

The code builds a VPC on us-east-1 region (same region as the infra VPC where cAPIC is deployed) with TGW, then creates two EPGs (Web & DB) which translates to 2 Security Groups, and enable Web access from Internet using contracts.

**Pre-requisites**

Cloud ACI running in AWS on a dedicated account/infra VPC. The Cloud APIC credentials and AWS account to be used for the user Tenant/VPC are defined in a variable file, as well as the name of the tenant.

**Providers**

| Name      | Version |
| --------- | ------- |
| [aci](https://registry.terraform.io/providers/CiscoDevNet/aci/latest)|  >=0.71   |

**Installation**

1. Install and setup your [terraform](https://www.terraform.io/downloads.html) environment
2. Simply copy the 2 files (main.tf and versions.tf) onto your terraform runtime environment
3. Create a variable.tf file with your Cloud APIC credentials and AWS account used for the user tenant/VPC

**Usage**

```
terraform init
terraform plan
terraform apply

```

**End State on Cloud ACI**

<img width="600" alt="aws" src="https://github.com/marinalf/cloudaci-demo-terraform-aws/blob/main/images/myapp.png">

**Cloud Networking**

<img width="600" alt="aws" src="https://github.com/marinalf/cloudaci-demo-terraform-aws/blob/main/images/vpc.png">
