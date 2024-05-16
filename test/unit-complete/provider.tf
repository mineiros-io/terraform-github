provider "github" {}

terraform {
  required_version = "~> 1.0"

  required_providers {
    github = {
      source = "integrations/github"
      # mask providers with broken branch protection v3 imlementation
      version = "~> 6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
  }
}
