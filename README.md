# Packer WordPress Deployment

This repository contains configuration files and scripts for provisioning a VM hosting Wordpress service using Packer and Terraform.

## Project Structure

The repository is organized into the following directories and files:

- **`packer/`**: Contains Packer configuration files for building a KVM image.
- **`terraform/`**: Contains Terraform configuration files for provisioning the VM.

## Prerequisites

- [Packer](https://www.packer.io/)
- [Terraform](https://www.terraform.io/)

## Usage

### 1. Build the KVM Image with Packer

1. Navigate to the repository directory.
2. Install required plugins
   ```bash
   sudo packer init wordpress.pkr.hcl
   ```
3. Build the image:
   ```bash
   sudo packer build wordpress.pkr.hcl
   ```
After this we get a KVM image with .img extension in the output directory
### 2. Provision VM with Terraform

1. Navigate to the repository directory.
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the Terraform Excecution Plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration to provision the infrastructure:
   ```bash
   terraform apply
   ```
5. Confirm the changes and wait for the VM to be provisioned
