# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A GITHUB REPOSITORY
# This module creates a GitHub repository with opinionated default settings.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Set some opinionated default settings through var.defaults and locals
locals {
  homepage_url           = var.homepage_url == null ? lookup(var.defaults, "homepage_url", "") : var.homepage_url
  private                = var.private == null ? lookup(var.defaults, "private", true) : var.private
  private_visibility     = local.private ? "private" : "public"
  visibility             = var.visibility == null ? lookup(var.defaults, "visibility", local.private_visibility) : var.visibility
  has_issues             = var.has_issues == null ? lookup(var.defaults, "has_issues", false) : var.has_issues
  has_projects           = var.has_projects == null ? lookup(var.defaults, "has_projects", false) : length(var.projects) > 0 ? true : var.has_projects
  has_wiki               = var.has_wiki == null ? lookup(var.defaults, "has_wiki", false) : var.has_wiki
  allow_merge_commit     = var.allow_merge_commit == null ? lookup(var.defaults, "allow_merge_commit", true) : var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge == null ? lookup(var.defaults, "allow_rebase_merge", false) : var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge == null ? lookup(var.defaults, "allow_squash_merge", false) : var.allow_squash_merge
  allow_auto_merge       = var.allow_auto_merge == null ? lookup(var.defaults, "allow_auto_merge", false) : var.allow_auto_merge
  delete_branch_on_merge = var.delete_branch_on_merge == null ? lookup(var.defaults, "delete_branch_on_merge", true) : var.delete_branch_on_merge
  is_template            = var.is_template == null ? lookup(var.defaults, "is_template", false) : var.is_template
  has_downloads          = var.has_downloads == null ? lookup(var.defaults, "has_downloads", false) : var.has_downloads
  auto_init              = var.auto_init == null ? lookup(var.defaults, "auto_init", true) : var.auto_init
  gitignore_template     = var.gitignore_template == null ? lookup(var.defaults, "gitignore_template", "") : var.gitignore_template
  license_template       = var.license_template == null ? lookup(var.defaults, "license_template", "") : var.license_template
  default_branch         = var.default_branch == null ? lookup(var.defaults, "default_branch", null) : var.default_branch
  standard_topics        = var.topics == null ? lookup(var.defaults, "topics", []) : var.topics
  topics                 = concat(local.standard_topics, var.extra_topics)
  template               = var.template == null ? [] : [var.template]
  issue_labels_create    = var.issue_labels_create == null ? lookup(var.defaults, "issue_labels_create", local.issue_labels_create_computed) : var.issue_labels_create

  issue_labels_create_computed = local.has_issues || length(var.issue_labels) > 0

  # for readability
  var_gh_labels = var.issue_labels_merge_with_github_labels
  gh_labels     = local.var_gh_labels == null ? lookup(var.defaults, "issue_labels_merge_with_github_labels", true) : local.var_gh_labels

  issue_labels_merge_with_github_labels = local.gh_labels
  # Per default, GitHub activates vulnerability  alerts for public repositories and disables it for private repositories
  vulnerability_alerts = var.vulnerability_alerts != null ? var.vulnerability_alerts : local.private ? false : true
}

locals {
  branch_protections_v3 = [
    for b in var.branch_protections_v3 : merge({
      branch                          = null
      enforce_admins                  = null
      require_conversation_resolution = null
      require_signed_commits          = null
      required_status_checks          = {}
      required_pull_request_reviews   = {}
      restrictions                    = {}
    }, b)
  ]

  required_status_checks = [
    for b in local.branch_protections_v3 :
    length(keys(b.required_status_checks)) > 0 ? [
      merge({
        strict   = null
        contexts = []
    }, b.required_status_checks)] : []
  ]

  required_pull_request_reviews = [
    for b in local.branch_protections_v3 :
    length(keys(b.required_pull_request_reviews)) > 0 ? [
      merge({
        dismiss_stale_reviews           = true
        dismissal_users                 = []
        dismissal_teams                 = []
        require_code_owner_reviews      = null
        required_approving_review_count = null
    }, b.required_pull_request_reviews)] : []
  ]

  restrictions = [
    for b in local.branch_protections_v3 :
    length(keys(b.restrictions)) > 0 ? [
      merge({
        users = []
        teams = []
        apps  = []
    }, b.restrictions)] : []
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the repository
# ---------------------------------------------------------------------------------------------------------------------

resource "github_repository" "repository" {
  name                   = var.name
  description            = var.description
  homepage_url           = local.homepage_url
  visibility             = local.visibility
  has_issues             = local.has_issues
  has_projects           = local.has_projects
  has_wiki               = local.has_wiki
  allow_merge_commit     = local.allow_merge_commit
  allow_rebase_merge     = local.allow_rebase_merge
  allow_squash_merge     = local.allow_squash_merge
  allow_auto_merge       = local.allow_auto_merge
  delete_branch_on_merge = local.delete_branch_on_merge
  is_template            = local.is_template
  has_downloads          = local.has_downloads
  auto_init              = local.auto_init
  gitignore_template     = local.gitignore_template
  license_template       = local.license_template
  archived               = var.archived
  topics                 = local.topics

  archive_on_destroy   = var.archive_on_destroy
  vulnerability_alerts = local.vulnerability_alerts

  dynamic "template" {
    for_each = local.template

    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
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

locals {
  branches_map = { for b in var.branches : b.name => b }
}

resource "github_branch" "branch" {
  for_each = local.branches_map

  repository    = github_repository.repository.name
  branch        = each.key
  source_branch = try(each.value.source_branch, null)
  source_sha    = try(each.value.source_sha, null)
}

# ---------------------------------------------------------------------------------------------------------------------
# Set default branch
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default
# ---------------------------------------------------------------------------------------------------------------------

resource "github_branch_default" "default" {
  count = local.default_branch != null ? 1 : 0

  repository = github_repository.repository.name
  branch     = local.default_branch

  depends_on = [github_branch.branch]
}

# ---------------------------------------------------------------------------------------------------------------------
# v4 Branch Protection
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection
# ---------------------------------------------------------------------------------------------------------------------

locals {
  branch_protections_v4_map = { for idx, e in var.branch_protections_v4 : try(e._key, e.pattern) => idx }
}

resource "github_branch_protection" "branch_protection" {
  for_each = local.branch_protections_v4_map

  # ensure we have all members and collaborators added before applying
  # any configuration for them
  depends_on = [
    github_repository_collaborator.collaborator,
    github_team_repository.team_repository,
    github_team_repository.team_repository_by_slug,
    github_branch.branch,
  ]

  repository_id = github_repository.repository.node_id

  pattern = var.branch_protections_v4[each.value].pattern

  allows_deletions                = try(var.branch_protections_v4[each.value].allows_deletions, false)
  allows_force_pushes             = try(var.branch_protections_v4[each.value].allows_force_pushes, false)
  blocks_creations                = try(var.branch_protections_v4[each.value].blocks_creations, false)
  enforce_admins                  = try(var.branch_protections_v4[each.value].enforce_admins, true)
  push_restrictions               = try(var.branch_protections_v4[each.value].push_restrictions, [])
  require_conversation_resolution = try(var.branch_protections_v4[each.value].require_conversation_resolution, false)
  require_signed_commits          = try(var.branch_protections_v4[each.value].require_signed_commits, false)
  required_linear_history         = try(var.branch_protections_v4[each.value].required_linear_history, false)

  dynamic "required_pull_request_reviews" {
    for_each = try([var.branch_protections_v4[each.value].required_pull_request_reviews], [])

    content {
      dismiss_stale_reviews           = try(required_pull_request_reviews.value.dismiss_stale_reviews, true)
      restrict_dismissals             = try(required_pull_request_reviews.value.restrict_dismissals, null)
      dismissal_restrictions          = try(required_pull_request_reviews.value.dismissal_restrictions, [])
      pull_request_bypassers          = try(required_pull_request_reviews.value.pull_request_bypassers, [])
      require_code_owner_reviews      = try(required_pull_request_reviews.value.require_code_owner_reviews, true)
      required_approving_review_count = try(required_pull_request_reviews.value.required_approving_review_count, 0)
    }
  }

  dynamic "required_status_checks" {
    for_each = try([var.branch_protections_v4[each.value].required_status_checks], [])

    content {
      strict   = try(required_status_checks.value.strict, false)
      contexts = try(required_status_checks.value.contexts, [])
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# v3 Branch Protection
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection_v3
# ---------------------------------------------------------------------------------------------------------------------

resource "github_branch_protection_v3" "branch_protection" {
  count = length(local.branch_protections_v3)

  # ensure we have all members and collaborators added before applying
  # any configuration for them
  depends_on = [
    github_repository_collaborator.collaborator,
    github_team_repository.team_repository,
    github_team_repository.team_repository_by_slug,
    github_branch.branch,
  ]

  repository                      = github_repository.repository.name
  branch                          = local.branch_protections_v3[count.index].branch
  enforce_admins                  = local.branch_protections_v3[count.index].enforce_admins
  require_conversation_resolution = local.branch_protections_v3[count.index].require_conversation_resolution
  require_signed_commits          = local.branch_protections_v3[count.index].require_signed_commits

  dynamic "required_status_checks" {
    for_each = local.required_status_checks[count.index]

    content {
      strict   = required_status_checks.value.strict
      contexts = required_status_checks.value.contexts
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = local.required_pull_request_reviews[count.index]

    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      dismissal_users                 = required_pull_request_reviews.value.dismissal_users
      dismissal_teams                 = [for t in required_pull_request_reviews.value.dismissal_teams : replace(lower(t), "/[^a-z0-9_]/", "-")]
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
    }
  }

  dynamic "restrictions" {
    for_each = local.restrictions[count.index]

    content {
      users = restrictions.value.users
      teams = [for t in restrictions.value.teams : replace(lower(t), "/[^a-z0-9_]/", "-")]
      apps  = restrictions.value.apps
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Issue Labels
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # only add to the list of labels even if github removes labels as changing this will affect
  # all deployed repositories.
  # add labels if new labels in github are added by default.
  # this is the set of labels and colors as of 2020-02-02
  github_default_issue_labels = local.issue_labels_merge_with_github_labels ? [
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
  for_each = local.issue_labels_create ? local.issue_labels : {}

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
