# Packer WordPress Deployment

This repository contains configuration files and scripts for provisioning a VM hosting Wordpress service using Packer and Terraform.

## Project Structure

The repository is organized into the following directories and files:

- **`packer/`**: Contains Packer configuration files for building a KVM image.
- **`terraform/`**: Contains Terraform configuration files for provisioning the VM.

## Prerequisites

- [Packer](https://www.packer.io/)
- [Terraform](https://www.terraform.io/)
- [QEMU](https://www.qemu.org/download/#linux)

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

### 2. Provision Infrastructure with Terraform

1. Navigate to the repository directory.
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Validate the Terraform configuration:
   ```bash
   terraform validate
   ```
4. Apply the configuration to provision the infrastructure:
   ```bash
   terraform apply
   ```
5. Confirm the changes and wait for the infrastructure to be provisioned.

### 3. Configure the Server with Cloud-Init

The `cloud-init` files in the `cloud-init/` directory will automatically configure the server during initialization. Ensure these files are referenced in your Packer or Terraform configurations.

## Customization

- Modify the `wordpress.pkr.hcl` file to customize the WordPress image.
- Update the `wordpress.tf` file to adjust the infrastructure settings (e.g., instance type, region, etc.).
- Edit the `cloud-init` files to change server initialization settings.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or fixes.

## Author

Created by [Your Name]. Feel free to reach out for any questions or feedback.

---

Happy deploying!