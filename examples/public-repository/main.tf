# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A PUBLIC REPOSITORY WITH AN ATTACHED TEAM
#   - create a public repository
#   - create a team and invite members
#   - add the team to the repository and grant admin permissions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

module "repository" {
  source  = "../.."

  module_depends_on = [
    module.team
  ]

  name               = "my-public-repository"
  description        = "A description of the repository."
  homepage_url       = "https://github.com/mineiros-io"
  visibility         = "public"
  has_issues         = true
  has_projects       = false
  has_wiki           = true
  allow_merge_commit = true
  allow_rebase_merge = false
  allow_squash_merge = false
  allow_auto_merge   = true
  auto_init          = true
  gitignore_template = "Terraform"
  license_template   = "mit"
  topics             = ["terraform", "unit-test"]

  admin_team_ids = [
    module.team.team.id
  ]

  webhooks = [
    {
      active       = true
      events       = ["issues"]
      url          = "https://example.com/events"
      content_type = "application/json"
      insecure_ssl = false
      secret       = "sososecret"
    },
  ]

  admin_collaborators = ["terraform-test-user-1"]

  branch_protections = {
    "main" = {
      enforce_admins                  = true
      require_conversation_resolution = true
      require_signed_commits          = true

      required_status_checks = {
        strict   = true
        checks   = ["ci/travis"]
      }

      required_pull_request_reviews = {
        dismiss_stale_reviews           = true
        dismissal_teams                 = [module.team.name]
        require_code_owner_reviews      = true
        required_approving_review_count = 1
      }

      restrictions = {
        teams = [module.team.name]
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# TEAM
# ---------------------------------------------------------------------------------------------------------------------

module "team" {
  source  = "github.com/kevcube/terraform-github-team?ref=a0b2c37"

  name        = "DevOps"
  description = "The DevOps Team"
  privacy     = "secret"

  # TEAM MEMBERSHIP
  # We are adding a member to this team: "terraform-test-user-2".
  # This existing users and already member of the GitHub Organization "terraform-test" that
  # is an Organization managed by Mineiros.io to run integration tests with Terratest.
  members = [
    "terraform-test-user-2",
  ]
}

# ------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES:
# ------------------------------------------------------------------------------
# You can provide your credentials via the
#   GITHUB_TOKEN and
#   GITHUB_OWNER, environment variables,
# representing your Access Token and the organization, respectively.
# ------------------------------------------------------------------------------
