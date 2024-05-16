# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE TWO REPOSITORIES WITH TEAMS AND DEFAULTS
# This example covers the whole functionality of the module. We create two different repositories and attach default
# settings. Also we create a single team and attach it to one of the repositories.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# DEPENDENCIES from other providers
# We are creating some resources for easier testing
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "deploy" {
  count = 2

  algorithm = "RSA"
  rsa_bits  = 4096
}

# ---------------------------------------------------------------------------------------------------------------------
# TEST A
# We are creating a repository, adding teams and setting up branch protection,
# deploy keys, issue labels and projects
# ---------------------------------------------------------------------------------------------------------------------

module "repository" {
  source = "../.."

  module_depends_on = [
    github_team.team
  ]

  name                   = var.name
  description            = var.description
  homepage_url           = var.url
  private                = false
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  allow_merge_commit     = var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  allow_auto_merge       = var.allow_auto_merge
  delete_branch_on_merge = var.delete_branch_on_merge
  is_template            = var.is_template
  has_downloads          = var.has_downloads
  auto_init              = var.auto_init
  gitignore_template     = var.gitignore_template
  license_template       = var.license_template
  archived               = false
  topics                 = var.topics
  archive_on_destroy     = false

  branches = [
    {
      name = "develop"
    },
    {
      name = "staging"
    },
  ]

  admin_collaborators = ["kevcube"]

  admin_team_ids = [
    github_team.team.id
  ]

  plaintext_secrets = {
    (var.secret_name) = var.secret_text
  }

  encrypted_secrets = {
    (var.encrypted_secret_name) = var.encrypted_secret_text
  }

  pages = {
    branch = "main"
    path   = "/"
  }

  webhooks = [{
    active       = var.webhook_active
    events       = var.webhook_events
    url          = var.webhook_url
    content_type = var.webhook_content_type
    insecure_ssl = var.webhook_insecure_ssl
    secret       = var.webhook_secret
  }]

  branch_protections_v4 = [
    {
      pattern = "staging"

      allows_deletions                = false
      allows_force_pushes             = false
      blocks_creations                = false
      enforce_admins                  = true
      require_conversation_resolution = true
      require_signed_commits          = true
      required_linear_history         = true

      required_pull_request_reviews = {
        dismiss_stale_reviews           = true
        require_code_owner_reviews      = true
        required_approving_review_count = 1
      }

      required_status_checks = {
        strict = true
      }
    }
  ]

  branch_protections_v3 = [
    {
      branch                          = "main"
      enforce_admins                  = true
      require_conversation_resolution = true
      require_signed_commits          = true

      required_status_checks = {
        strict = true
        checks = ["ci/travis"]
      }

      required_pull_request_reviews = {
        dismiss_stale_reviews           = true
        dismissal_users                 = [var.team_user]
        dismissal_teams                 = [github_team.team.name]
        require_code_owner_reviews      = true
        required_approving_review_count = 1
      }

      restrictions = {
        users = [var.team_user]
        teams = [github_team.team.name]
      }
    },
    {
      branch                 = "develop"
      enforce_admins         = true
      require_signed_commits = true
    }
  ]

  issue_labels = var.issue_labels

  deploy_keys_computed = [
    {
      title     = "CI User Deploy Key"
      key       = tls_private_key.deploy[0].public_key_openssh
      read_only = true
    },
    tls_private_key.deploy[1].public_key_openssh
  ]

  projects = var.projects

  autolink_references = var.autolink_references

  app_installations = var.app_installations
}

# ---------------------------------------------------------------------------------------------------------------------
# TEST B
# We are creating a repository using some defaults defined in
# var.repository_defaults
# ---------------------------------------------------------------------------------------------------------------------

module "repository-with-defaults" {
  source = "../.."

  name               = var.repository_with_defaults_name
  description        = var.repository_with_defaults_description
  defaults           = var.repository_defaults
  default_branch     = "development"
  archive_on_destroy = false

  branches = [
    { name = "development" },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# GITHUB DEPENDENCIES: TEAM
# We are creating a github team to be added to the repository
# ---------------------------------------------------------------------------------------------------------------------

resource "github_team" "team" {
  name        = var.team_name
  description = var.team_description
  privacy     = "secret"
}

# ----------------------------------------------------------------------------------------------------------------------
# TEAM MEMBERSHIP
# We are adding one members to this team for testing branch restrictions.
# The user defined in "var.team_user" should be a permanent normal member of organization you run the tests in.
# ----------------------------------------------------------------------------------------------------------------------

resource "github_team_membership" "team_membership_permanent" {
  team_id  = github_team.team.id
  username = var.team_user
  role     = "member"
}
