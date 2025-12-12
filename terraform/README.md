# Terraform (EKS Simulation)

This folder contains Terraform configuration to **simulate an EKS-style infrastructure**.
It is intended for validation and review (no real AWS account is required to run `terraform validate`).

Files:
- versions.tf — terraform/provider requirements
- variables.tf — configurable variables
- main.tf — VPC, subnets, IAM roles, EKS cluster & managed node group
- outputs.tf — useful outputs
- terraform.tfvars — example variable values

## How to validate locally

1. Install Terraform (>=1.1.0)
2. cd terraform
3. terraform init
4. terraform validate
5. terraform plan  
## Security scanning
- tfsec: `tfsec .`
- checkov: `checkov -d .`

## Mapping to real EKS (short)
- aws_vpc -> VPC for EKS
- aws_subnet (public/private) -> subnets mapped to EKS node groups and control plane networking
- aws_iam_role.eks_cluster_role -> EKS control plane role (AmazonEKSClusterPolicy)
- aws_iam_role.eks_node_role -> Node group IAM role for worker nodes (EKS worker policies)
- aws_eks_cluster -> managed EKS control plane
- aws_eks_node_group -> managed node group (EC2-based workers)

