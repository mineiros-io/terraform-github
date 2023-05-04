provider "github" {}

terraform {
  required_version = "~> 1.0"

  required_providers {
    github = {
      source = "integrations/github"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 2.1"
    }
  }
}
