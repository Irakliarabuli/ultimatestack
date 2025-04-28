
# Docker Terraform Setup for n8n, Supabase, and Ngrok

This Terraform configuration sets up a Docker environment with n8n, Supabase, and Ngrok.

## Prerequisites

- Docker installed and running
- Terraform installed
- Ngrok account and auth token

## Setup Instructions

1. Initialize Terraform:
```bash
terraform init
```

2. Set your Ngrok authentication token:
```bash
export TF_VAR_ngrok_auth_token="your_ngrok_auth_token"
```

3. Apply the Terraform configuration:
```bash
terraform apply
```

4. Access the services:
   - n8n: http://localhost:5678
   - Supabase: http://localhost:8000
   - Ngrok UI: http://localhost:4040

## Data Persistence

Data is persisted in the following directories:
- n8n data: ./data/n8n
- Supabase data: ./data/supabase

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```
