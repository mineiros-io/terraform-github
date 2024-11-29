# ---------------------------------------------------------------------------------------------------------------------
# SET TERRAFORM AND PROVIDER REQUIREMENTS FOR RUNNING THIS MODULE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = "~> 1.0"

  # branch_protections_v3 are broken in >= 5.3
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.8, < 6.0"
    }
  }
}
