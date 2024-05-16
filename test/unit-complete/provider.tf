provider "github" {
  owner = "kbc-trading"
}

terraform {
  required_version = "~> 1.0"

  required_providers {
    github = {
      source = "integrations/github"
      # mask providers with broken branch protection v3 imlementation
      version = "~> 5.0, !=5.3.0, !=5.4.0, !=5.5.0, !=5.6.0, !=5.7.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
  }
}
