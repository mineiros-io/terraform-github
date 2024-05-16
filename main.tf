# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A GITHUB REPOSITORY
# This module creates a GitHub repository with opinionated default settings.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

locals {
  # for readability
  # var_gh_labels = var.issue_labels_merge_with_github_labels

  # issue_labels_merge_with_github_labels = var.gh_labels
  # Per default, GitHub activates vulnerability  alerts for public repositories and disables it for private repositories
  vulnerability_alerts = coalesce(var.vulnerability_alerts, var.visibility == "public" ? true : false)
}

# locals {
#   branch_protections_v3 = [
#     for b in var.branch_protections_v3 : merge({
#       branch                          = null
#       enforce_admins                  = null
#       require_conversation_resolution = null
#       require_signed_commits          = null
#       required_status_checks          = {}
#       required_pull_request_reviews   = {}
#       restrictions                    = {}
#     }, b)
#   ]

#   required_status_checks = [
#     for b in local.branch_protections_v3 :
#     length(keys(b.required_status_checks)) > 0 ? [
#       merge({
#         strict = null
#         checks = []
#     }, b.required_status_checks)] : []
#   ]

#   required_pull_request_reviews = [
#     for b in local.branch_protections_v3 :
#     length(keys(b.required_pull_request_reviews)) > 0 ? [
#       merge({
#         dismiss_stale_reviews           = true
#         dismissal_users                 = []
#         dismissal_teams                 = []
#         require_code_owner_reviews      = null
#         required_approving_review_count = null
#     }, b.required_pull_request_reviews)] : []
#   ]

#   restrictions = [
#     for b in local.branch_protections_v3 :
#     length(keys(b.restrictions)) > 0 ? [
#       merge({
#         users = []
#         teams = []
#         apps  = []
#     }, b.restrictions)] : []
#   ]
# }

# ---------------------------------------------------------------------------------------------------------------------
# Create the repository
# ---------------------------------------------------------------------------------------------------------------------

resource "github_repository" "repository" {
  name                   = var.name
  description            = var.description
  homepage_url           = var.homepage_url
  visibility             = var.visibility
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  allow_merge_commit     = var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  allow_auto_merge       = var.allow_auto_merge
  delete_branch_on_merge = var.delete_branch_on_merge
  is_template            = var.is_template
  auto_init              = var.auto_init
  gitignore_template     = var.gitignore_template
  license_template       = var.license_template
  archived               = var.archived
  topics                 = var.topics

  merge_commit_message = var.merge_commit_message
  merge_commit_title   = var.merge_commit_title

  squash_merge_commit_message = var.squash_merge_commit_message
  squash_merge_commit_title   = var.squash_merge_commit_title

  archive_on_destroy   = var.archive_on_destroy
  vulnerability_alerts = local.vulnerability_alerts

  dynamic "template" {
    for_each = var.template != null ? [true] : []

    content {
      owner                = var.template.value.owner
      repository           = var.template.value.repository
      include_all_branches = var.template.value.include_all_branches
    }
  }

  dynamic "pages" {
    for_each = var.pages != null ? [true] : []

    content {
      source {
        branch = var.pages.branch
        path   = try(var.pages.path, "/")
      }
      cname = try(var.pages.cname, null)
    }
  }

  lifecycle {
    ignore_changes = [
      auto_init,
      license_template,
      gitignore_template,
      template,
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Manage branches
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch
# ---------------------------------------------------------------------------------------------------------------------

resource "github_branch" "branch" {
  for_each = var.branches

  repository    = github_repository.repository.name
  branch        = each.key
  source_branch = each.value.source_branch
  source_sha    = each.value.source_sha
}

# ---------------------------------------------------------------------------------------------------------------------
# Set default branch
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default
# ---------------------------------------------------------------------------------------------------------------------

resource "github_branch_default" "default" {
  count = var.default_branch != null ? 1 : 0

  repository = github_repository.repository.name
  branch     = var.default_branch
}

# ---------------------------------------------------------------------------------------------------------------------
# Branch Protection
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection
# ---------------------------------------------------------------------------------------------------------------------

resource "github_branch_protection" "branch_protection" {
  #checkov:skip=CKV_GIT_6:Signed commits are not required
  for_each = var.branch_protections

  # ensure we have all members and collaborators added before applying
  # any configuration for them
  depends_on = [
    github_repository_collaborator.collaborator,
    github_team_repository.team_repository,
    github_team_repository.team_repository_by_slug,
    github_branch.branch,
  ]

  repository_id = github_repository.repository.node_id

  pattern = each.key

  enforce_admins                  = each.value.enforce_admins
  require_signed_commits          = each.value.require_signed_commits
  required_linear_history         = each.value.required_linear_history
  require_conversation_resolution = each.value.require_conversation_resolution

  dynamic "required_status_checks" {
    for_each = try([each.value.required_status_checks], [])

    content {
      strict   = required_status_checks.strict
      contexts = required_status_checks.contexts
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = try([each.value.required_pull_request_reviews], [])

    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      restrict_dismissals             = required_pull_request_reviews.value.restrict_dismissals
      dismissal_restrictions          = required_pull_request_reviews.value.dismissal_restrictions
      pull_request_bypassers          = required_pull_request_reviews.value.pull_request_bypassers
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
      require_last_push_approval      = required_pull_request_reviews.value.require_last_push_approval
    }
  }

  dynamic "restrict_pushes" {
    for_each = try([each.value.restrict_pushes], [])

    content {
      blocks_creations = restrict_pushes.blocks_creations
      push_allowances  = restrict_pushes.push_allowances
    }
  }

  force_push_bypassers = each.value.force_push_bypassers
  allows_deletions     = each.value.allows_deletions
  allows_force_pushes  = each.value.allows_force_pushes
  lock_branch          = each.value.lock_branch
}

# ---------------------------------------------------------------------------------------------------------------------
# Issue Labels
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # only add to the list of labels even if github removes labels as changing this will affect
  # all deployed repositories.
  # add labels if new labels in github are added by default.
  # this is the set of labels and colors as of 2020-02-02
  github_default_issue_labels = var.issue_labels_merge_with_github_labels ? [
    {
      name        = "bug"
      description = "Something isn't working"
      color       = "d73a4a"
    },
    {
      name        = "documentation"
      description = "Improvements or additions to documentation"
      color       = "0075ca"
    },
    {
      name        = "duplicate"
      description = "This issue or pull request already exists"
      color       = "cfd3d7"
    },
    {
      name        = "enhancement"
      description = "New feature or request"
      color       = "a2eeef"
    },
    {
      name        = "good first issue"
      description = "Good for newcomers"
      color       = "7057ff"
    },
    {
      name        = "help wanted"
      description = "Extra attention is needed"
      color       = "008672"
    },
    {
      name        = "invalid"
      description = "This doesn't seem right"
      color       = "e4e669"
    },
    {
      name        = "question"
      description = "Further information is requested"
      color       = "d876e3"
    },
    {
      name        = "wontfix"
      description = "This will not be worked on"
      color       = "ffffff"
    }
  ] : []

  github_issue_labels = { for i in local.github_default_issue_labels : i.name => i }

  module_issue_labels = { for i in var.issue_labels : lookup(i, "id", lower(i.name)) => merge({
    description = null
  }, i) }

  issue_labels = merge(local.github_issue_labels, local.module_issue_labels)
}

resource "github_issue_label" "label" {
  for_each = var.issue_labels_create ? local.issue_labels : {}

  repository  = github_repository.repository.name
  name        = each.value.name
  description = each.value.description
  color       = each.value.color
}

# ---------------------------------------------------------------------------------------------------------------------
# Collaborators
# ---------------------------------------------------------------------------------------------------------------------

locals {
  collab_admin    = { for i in var.admin_collaborators : i => "admin" }
  collab_push     = { for i in var.push_collaborators : i => "push" }
  collab_pull     = { for i in var.pull_collaborators : i => "pull" }
  collab_triage   = { for i in var.triage_collaborators : i => "triage" }
  collab_maintain = { for i in var.maintain_collaborators : i => "maintain" }

  collaborators = merge(
    local.collab_admin,
    local.collab_push,
    local.collab_pull,
    local.collab_triage,
    local.collab_maintain,
  )
}

resource "github_repository_collaborator" "collaborator" {
  for_each = local.collaborators

  repository = github_repository.repository.name
  username   = each.key
  permission = each.value
}

# ---------------------------------------------------------------------------------------------------------------------
# Teams by id
# ---------------------------------------------------------------------------------------------------------------------

locals {
  team_id_admin    = [for i in var.admin_team_ids : { team_id = i, permission = "admin" }]
  team_id_push     = [for i in var.push_team_ids : { team_id = i, permission = "push" }]
  team_id_pull     = [for i in var.pull_team_ids : { team_id = i, permission = "pull" }]
  team_id_triage   = [for i in var.triage_team_ids : { team_id = i, permission = "triage" }]
  team_id_maintain = [for i in var.maintain_team_ids : { team_id = i, permission = "maintain" }]

  team_ids = concat(
    local.team_id_admin,
    local.team_id_push,
    local.team_id_pull,
    local.team_id_triage,
    local.team_id_maintain,
  )
}

resource "github_team_repository" "team_repository" {
  count = length(local.team_ids)

  repository = github_repository.repository.name
  team_id    = local.team_ids[count.index].team_id
  permission = local.team_ids[count.index].permission
}

# ---------------------------------------------------------------------------------------------------------------------
# Teams by name
# ---------------------------------------------------------------------------------------------------------------------

locals {
  team_admin    = [for i in var.admin_teams : { slug = replace(lower(i), "/[^a-z0-9_]/", "-"), permission = "admin" }]
  team_push     = [for i in var.push_teams : { slug = replace(lower(i), "/[^a-z0-9_]/", "-"), permission = "push" }]
  team_pull     = [for i in var.pull_teams : { slug = replace(lower(i), "/[^a-z0-9_]/", "-"), permission = "pull" }]
  team_triage   = [for i in var.triage_teams : { slug = replace(lower(i), "/[^a-z0-9_]/", "-"), permission = "triage" }]
  team_maintain = [for i in var.maintain_teams : { slug = replace(lower(i), "/[^a-z0-9_]/", "-"), permission = "maintain" }]

  teams = { for i in concat(
    local.team_admin,
    local.team_push,
    local.team_pull,
    local.team_triage,
    local.team_maintain,
  ) : i.slug => i }
}

resource "github_team_repository" "team_repository_by_slug" {
  for_each = local.teams

  repository = github_repository.repository.name
  team_id    = each.value.slug
  permission = each.value.permission

  depends_on = [var.module_depends_on]
}

# ---------------------------------------------------------------------------------------------------------------------
# Deploy Keys
# ---------------------------------------------------------------------------------------------------------------------

locals {
  deploy_keys_computed_temp = [
    for d in var.deploy_keys_computed : try({ key = tostring(d) }, d)
  ]

  deploy_keys_computed = [
    for d in local.deploy_keys_computed_temp : merge({
      title     = length(split(" ", d.key)) > 2 ? element(split(" ", d.key), 2) : md5(d.key)
      read_only = true
    }, d)
  ]
}

resource "github_repository_deploy_key" "deploy_key_computed" {
  count = length(local.deploy_keys_computed)

  repository = github_repository.repository.name
  title      = local.deploy_keys_computed[count.index].title
  key        = local.deploy_keys_computed[count.index].key
  read_only  = local.deploy_keys_computed[count.index].read_only
}

locals {
  deploy_keys_temp = [
    for d in var.deploy_keys : try({ key = tostring(d) }, d)
  ]

  deploy_keys = {
    for d in local.deploy_keys_temp : lookup(d, "id", md5(d.key)) => merge({
      title     = length(split(" ", d.key)) > 2 ? element(split(" ", d.key), 2) : md5(d.key)
      read_only = true
    }, d)
  }
}

resource "github_repository_deploy_key" "deploy_key" {
  for_each = local.deploy_keys

  repository = github_repository.repository.name
  title      = each.value.title
  key        = each.value.key
  read_only  = each.value.read_only
}

# ---------------------------------------------------------------------------------------------------------------------
# Projects
# ---------------------------------------------------------------------------------------------------------------------

locals {
  projects = { for i in var.projects : lookup(i, "id", lower(i.name)) => merge({
    body = null
  }, i) }
}

resource "github_repository_project" "repository_project" {
  for_each = local.projects

  repository = github_repository.repository.name
  name       = each.value.name
  body       = each.value.body
}

# ---------------------------------------------------------------------------------------------------------------------
# Webhooks
# ---------------------------------------------------------------------------------------------------------------------

resource "github_repository_webhook" "repository_webhook" {
  count = length(var.webhooks)

  repository = github_repository.repository.name
  # the optional `name` attribute causes an error so it has been removed
  # > Error: "name": [REMOVED] The `name` attribute is no longer necessary.
  active = try(var.webhooks[count.index].active, true)
  events = var.webhooks[count.index].events

  configuration {
    url          = var.webhooks[count.index].url
    content_type = try(var.webhooks[count.index].content_type, "json")
    insecure_ssl = try(var.webhooks[count.index].insecure_ssl, false)
    secret       = try(var.webhooks[count.index].secret, null)
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Autolink References
# ---------------------------------------------------------------------------------------------------------------------

locals {
  autolink_references = { for i in var.autolink_references : lookup(i, "id", lower(i.key_prefix)) => merge({
    target_url_template = null
  }, i) }
}

resource "github_repository_autolink_reference" "repository_autolink_reference" {
  for_each = local.autolink_references

  repository          = github_repository.repository.name
  key_prefix          = each.value.key_prefix
  target_url_template = each.value.target_url_template
}

# ---------------------------------------------------------------------------------------------------------------------
# App installation
# ---------------------------------------------------------------------------------------------------------------------

resource "github_app_installation_repository" "app_installation_repository" {
  for_each = var.app_installations

  repository      = github_repository.repository.name
  installation_id = each.value
}
