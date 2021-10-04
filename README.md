Cloud ACI in AWS

Use Case: Single Region/Tenant/VRF

This script builds an user VPC on a single region (same region as the infra VPC where cAPIC is deployed) with a shared TGW, creates two EPGs (Web & DB) which translates to 2 Security Groups, and enable Web access to/from Internet.

High Level AWS setup

<img width="950" alt="aws" src="https://github.com/marinalf/cloudaci-demo-terraform-aws/blob/main/aws.png">

Web to DB communication

<img width="1018" alt="web-to-db" src="https://github.com/marinalf/cloudaci-demo-terraform-aws/blob/main/web-to-db.png">

Web to Internet communication

<img width="1008" alt="web-to-internet" src="https://github.com/marinalf/cloudaci-demo-terraform-aws/blob/main/web-to-internet.png">
