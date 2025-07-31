# IAM Multi-user Terraform

A Terraform project for managing AWS IAM users and roles with configurable permissions based on YAML configuration.

## Overview

This project creates AWS IAM users and assigns them to predefined roles based on a YAML configuration file. It supports multiple role types including admin, readonly, billing, and audit permissions.

## Project Structure

```
├── provider.tf      # AWS provider configuration
├── users.tf         # IAM user creation and login profiles
├── roles.tf         # IAM roles and policy attachments
├── users_info.yaml  # User configuration file
└── README.md        # This file
```

## Supported Roles

- **admin**: AdministratorAccess
- **readonly**: ReadOnlyAccess
- **billing**: Billing
- **audit**: SecurityAudit

## Configuration

Edit `users_info.yaml` to define users and their roles:

```yaml
users:
- username: Rocky
  roles: [admin]
- username: Chadwick
  roles: [readonly]
- username: John
  roles: [Audit,Billing]
```

## Usage

1. Configure AWS credentials
2. Update `users_info.yaml` with your users
3. Run Terraform commands:

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `account_id`: Current AWS account ID
- `users_info_output`: List of configured users
- `passwords`: Generated passwords (sensitive)
- `iam_roles_created`: Created IAM roles
- `user_role_mapping`: User to role mappings

## Requirements

- Terraform >= 1.0
- AWS Provider 6.6.0
- Valid AWS credentials