
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create a custom network for our containers
resource "docker_network" "app_network" {
  name = "app_network"
}

# n8n container
resource "docker_container" "n8n" {
  name  = "n8n"
  image = "n8nio/n8n:latest"
  
  ports {
    internal = 5678
    external = 5678
  }
  
  env = [
    "N8N_PORT=5678",
    "NODE_ENV=production",
    "WEBHOOK_URL=https://${docker_container.ngrok.name}.ngrok.io",
    "DB_TYPE=postgresdb",
    "DB_POSTGRESDB_HOST=${docker_container.supabase.name}",
    "DB_POSTGRESDB_PORT=5432",
    "DB_POSTGRESDB_DATABASE=postgres",
    "DB_POSTGRESDB_USER=postgres",
    "DB_POSTGRESDB_PASSWORD=postgres"
  ]
  
  volumes {
    container_path = "/home/node/.n8n"
    host_path      = "./data/n8n"
  }
  
  networks_advanced {
    name = docker_network.app_network.name
  }
  
  depends_on = [
    docker_container.supabase,
    docker_container.ngrok
  ]
}

# Supabase container
resource "docker_container" "supabase" {
  name  = "supabase"
  image = "supabase/supabase-postgres:latest"
  
  ports {
    internal = 5432
    external = 5432
  }
  
  ports {
    internal = 8000
    external = 8000
  }
  
  env = [
    "POSTGRES_PASSWORD=postgres",
    "POSTGRES_USER=postgres",
    "POSTGRES_DB=postgres"
  ]
  
  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = "./data/supabase"
  }
  
  networks_advanced {
    name = docker_network.app_network.name
  }
}

# Ngrok container
resource "docker_container" "ngrok" {
  name  = "ngrok"
  image = "ngrok/ngrok:latest"
  
  ports {
    internal = 4040
    external = 4040
  }
  
  command = ["http", "n8n:5678"]
  
  env = [
    "NGROK_AUTHTOKEN=${var.ngrok_auth_token}"
  ]
  
  networks_advanced {
    name = docker_network.app_network.name
  }
}
