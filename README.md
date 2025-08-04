# Terraform VPC Lab

This project was created as part of the Ironhack DevOps Bootcamp.

It uses **Terraform** to deploy a basic AWS infrastructure, including:

- A Virtual Private Cloud (VPC)
- A public subnet
- An Internet Gateway (IGW)
- A route table and its association
- A security group for SSH access
- A single EC2 instance with a public IP

## How to Use

Make sure you have:
- AWS CLI and credentials set up
- Terraform installed
- A key pair in AWS EC2 for SSH access

To deploy:

```bash
terraform init
terraform apply -var="key_pair_name=your-key-name"
```

To destroy:

```bash
terraform destroy -var="key_pair_name=your-key-name"
```

> **Warning**: Do not commit `.pem` key files or `.terraform` folders.

