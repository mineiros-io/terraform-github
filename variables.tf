# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "(Required) The name of the repository."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults, but may be overridden.
# ---------------------------------------------------------------------------------------------------------------------

variable "branches" {
  description = "(Optional) A list of branches to be created in this repository."
  type        = any
  # type = list(object({
  #   name          = string
  #   source_branch = optional(string)
  #   source_sha    = optional(string)
  # }))
  default = []
}

variable "defaults" {
  description = "(Deprecated) DEPRECATED. Please convert defaults to Terraform Module for_each"
  type        = any
  default     = {}
}

variable "description" {
  description = "(Optional) A description of the repository."
  type        = string
  default     = ""
}

variable "homepage_url" {
  description = "(Optional) The website of the repository."
  type        = string
  default     = null
}

variable "private" {
  description = "(Optional) (DEPRECATED: use visibility)"
  type        = bool
  default     = null
}

variable "visibility" {
  description = "(Optional) Can be 'public', 'private' or 'internal' (GHE only).The visibility parameter overrides the private parameter. Defaults to 'private' if neither private nor visibility are set, default to state of private parameter if it is set."
  type        = string
  default     = null
}

variable "has_issues" {
  description = "(Optional) Set to true to enable the GitHub Issues features on the repository. (Default: false)"
  type        = bool
  default     = null
}

variable "has_projects" {
  description = "(Optional) Set to true to enable the GitHub Projects features on the repository. Per the github documentation when in an organization that has disabled repository projects it will default to false and will otherwise default to true. If you specify true when it has been disabled it will return an error.  (Default: false)"
  type        = bool
  default     = null
}

variable "has_wiki" {
  description = "(Optional) Set to true to enable the GitHub Wiki features on the repository. (Default: false)"
  type        = bool
  default     = null
}

variable "allow_merge_commit" {
  description = "(Optional) Set to false to disable merge commits on the repository. (Default: true)"
  type        = bool
  default     = null
}

variable "allow_squash_merge" {
  description = "(Optional) Set to true to enable squash merges on the repository. (Default: false)"
  type        = bool
  default     = null
}

variable "allow_rebase_merge" {
  description = "(Optional) Set to true to enable rebase merges on the repository. (Default: false)"
  type        = bool
  default     = null
}

variable "allow_auto_merge" {
  description = "(Optional) Set to true to allow auto-merging pull requests on the repository. If enabled for a pull request, the pull request will merge automatically when all required reviews are met and status checks have passed. (Default: false)"
  type        = bool
  default     = null
}

variable "delete_branch_on_merge" {
  description = "(Optional) Whether or not to delete the merged branch after merging a pull request. (Default: false)"
  type        = bool
  default     = null
}

variable "has_downloads" {
  description = "(Optional) Set to true to enable the (deprecated) downloads features on the repository. (Default: false)"
  type        = bool
  default     = null
}

variable "auto_init" {
  description = "(Optional) Wether or not to produce an initial commit in the repository. (Default: true)"
  type        = bool
  default     = null
}

variable "pages" {
  description = "(Optional) The repository's GitHub Pages configuration. (Default: {})"
  # type = object({
  # branch = string
  # path   = string
  # cname  = string
  # })
  type    = any
  default = null
}

variable "gitignore_template" {
  description = "(Optional) Use the name of the template without the extension. For example, Haskell. Available templates: https://github.com/github/gitignore"
  type        = string
  default     = null
}

variable "is_template" {
  description = "(Optional) Whether or not to tell GitHub that this is a template repository. ( Default: false)"
  type        = bool
  default     = null
}

variable "license_template" {
  description = "(Optional) Use the name of the template without the extension. For example, 'mit' or 'mpl-2.0'. Available licences: https://github.com/github/choosealicense.com/tree/gh-pages/_licenses"
  type        = string
  default     = null
}

variable "default_branch" {
  description = "(Optional) The name of the default branch of the repository. NOTE: This can only be set after a repository has already been created, and after a correct reference has been created for the target branch inside the repository. This means a user will have to omit this parameter from the initial repository creation and create the target branch inside of the repository prior to setting this attribute."
  type        = string
  default     = null
}

variable "archived" {
  description = "(Optional) Specifies if the repository should be archived. (Default: false)"
  type        = bool
  default     = false
}

variable "topics" {
  description = "(Optional) The list of topics of the repository.  (Default: [])"
  type        = list(string)
  default     = null
}

variable "extra_topics" {
  description = "(Optional) The list of additional topics of the repository. (Default: [])"
  type        = list(string)
  default     = []
}

variable "template" {
  description = "(Optional) Template repository to use. (Default: {})"
  type = object({
    owner                = string
    repository           = string
    include_all_branches = bool
  })
  default = null
}

variable "admin_collaborators" {
  description = "(Optional) A list of users to add as collaborators granting them admin (full) permission."
  type        = list(string)
  default     = []
}

variable "push_collaborators" {
  description = "(Optional) A list of users to add as collaborators granting them push (read-write) permission."
  type        = list(string)
  default     = []
}

variable "pull_collaborators" {
  description = "(Optional) A list of users to add as collaborators granting them pull (read-only) permission."
  type        = list(string)
  default     = []
}

variable "triage_collaborators" {
  description = "(Optional) A list of users to add as collaborators granting them triage permission."
  type        = list(string)
  default     = []
}

variable "maintain_collaborators" {
  description = "(Optional) A list of users to add as collaborators granting them maintain permission."
  type        = list(string)
  default     = []
}

variable "admin_team_ids" {
  description = "(Optional) A list of teams (by id) to grant admin (full) permission to."
  type        = list(string)
  default     = []
}

variable "push_team_ids" {
  description = "(Optional) A list of teams (by id) to grant push (read-write) permission to."
  type        = list(string)
  default     = []
}

variable "pull_team_ids" {
  description = "(Optional) A list of teams (by id) to grant pull (read-only) permission to."
  type        = list(string)
  default     = []
}

variable "triage_team_ids" {
  description = "(Optional) A list of teams (by id) to grant triage permission to."
  type        = list(string)
  default     = []
}

variable "maintain_team_ids" {
  description = "(Optional) A list of teams (by id) to grant maintain permission to."
  type        = list(string)
  default     = []
}

variable "admin_teams" {
  description = "(Optional) A list of teams (by name/slug) to grant admin (full) permission to."
  type        = list(string)
  default     = []
}

variable "push_teams" {
  description = "(Optional) A list of teams (by name/slug) to grant push (read-write) permission to."
  type        = list(string)
  default     = []
}

variable "pull_teams" {
  description = "(Optional) A list of teams (by name/slug) to grant pull (read-only) permission to."
  type        = list(string)
  default     = []
}

variable "triage_teams" {
  description = "(Optional) A list of teams (by name/slug) to grant triage permission to."
  type        = list(string)
  default     = []
}

variable "maintain_teams" {
  description = "(Optional) A list of teams (by name/slug) to grant maintain permission to."
  type        = list(string)
  default     = []
}

variable "branch_protections_v3" {
  description = "(Optional) A list of branch protections to apply to the repository. Default is [] unless branch_protections is set."
  type        = any

  # We can't use a detailed type specification due to a terraform limitation. However, this might be changed in a future
  # Terraform version. See https://github.com/hashicorp/terraform/issues/19898 and https://github.com/hashicorp/terraform/issues/22449
  #
  # type = list(object({
  #   branch                 = string
  #   enforce_admins         = bool
  #   require_signed_commits = bool
  #   required_status_checks = object({
  #     strict   = bool
  #     contexts = list(string)
  #   })
  #   required_pull_request_reviews = object({
  #     dismiss_stale_reviews           = bool
  #     dismissal_users                 = list(string)
  #     dismissal_teams                 = list(string)
  #     require_code_owner_reviews      = bool
  #     required_approving_review_count = number
  #   })
  #   restrictions = object({
  #     users = list(string)
  #     teams = list(string)
  #   })
  # }))

  default = []

  # Example:
  # branch_protections = [
  #   {
  #     branch                 = "main"
  #     enforce_admins         = true
  #     require_signed_commits = true
  #
  #     required_status_checks = {
  #       strict   = false
  #       contexts = ["ci/travis"]
  #     }
  #
  #     required_pull_request_reviews = {
  #       dismiss_stale_reviews           = true
  #       dismissal_users                 = ["user1", "user2"]
  #       dismissal_teams                 = ["team-slug-1", "team-slug-2"]
  #       require_code_owner_reviews      = true
  #       required_approving_review_count = 1
  #     }
  #
  #     restrictions = {
  #       users = ["user1"]
  #       teams = ["team-slug-1"]
  #     }
  #   }
  # ]
}

variable "branch_protections_v4" {
  description = "(Optional) A list of v4 branch protections to apply to the repository. Default is []."
  type        = any
  # type = list(
  #   object(
  #     {
  #       pattern                         = string
  #       allows_deletions                = optional(bool, false)
  #       allows_force_pushes             = optional(bool, false)
  #       blocks_creations                = optional(bool, false)
  #       enforce_admins                  = optional(bool, false)
  #       push_restrictions               = optional(list(string), [])
  #       require_conversation_resolution = optional(bool, false)
  #       require_signed_commits          = optional(bool, false)
  #       required_linear_history         = optional(bool, false)
  #       required_pull_request_reviews = optional(object(
  #         {
  #           dismiss_stale_reviews           = optional(bool, false)
  #           dismissal_restrictions          = optional(list(string), [])
  #           pull_request_bypassers          = optional(list(string), [])
  #           require_code_owner_reviews      = optional(bool, false)
  #           required_approving_review_count = optional(number, 0)
  #         }
  #       ))
  #       required_status_checks = optional(object(
  #         {
  #           strict   = optional(bool, false)
  #           contexts = optional(list(string), [])
  #         }
  #       ))
  #     }
  #   )
  # )
  default = []

  validation {
    condition = alltrue(
      [
        for cfg in var.branch_protections_v4 : try(
          cfg.required_pull_request_reviews.required_approving_review_count >= 0
          && cfg.required_pull_request_reviews.required_approving_review_count <= 6,
          true
        )
      ]
    )
    error_message = "The value for branch_protections_v4.required_pull_request_reviews.required_approving_review_count must be between 0 and 6, inclusively."
  }
}

variable "issue_labels_merge_with_github_labels" {
  description = "(Optional) Specify if you want to merge and control githubs default set of issue labels."
  type        = bool
  default     = null
}

variable "issue_labels_create" {
  description = "(Optional) Specify whether you want to force or suppress the creation of issues labels."
  type        = bool
  default     = null
}

variable "issue_labels" {
  description = "(Optional) Configure a GitHub issue label resource."
  type = list(object({
    name        = string
    description = string
    color       = string
  }))

  # Example:
  # issue_labels = [
  #   {
  #     name        = "WIP"
  #     description = "Work in Progress..."
  #     color       = "d6c860"
  #   },
  #   {
  #     name        = "another-label"
  #     description = "This is a lable created by Terraform..."
  #     color       = "1dc34f"
  #   }
  # ]

  default = []
}

variable "deploy_keys" {
  description = "(Optional) Configure a deploy key ( SSH key ) that grants access to a single GitHub repository. This key is attached directly to the repository instead of to a personal user account."
  type        = any

  # Example:
  # deploy_keys = [
  #   {
  #     title     = "CI User Deploy Key"
  #     key       = "ssh-rsa AAAAB3NzaC1yc2...."
  #     read_only = true
  #   },
  #   {
  #     title     = "Test Key"
  #     key       = "ssh-rsa AAAAB3NzaC1yc2...."
  #     read_only = false
  #   }
  # ]

  default = []
}

variable "deploy_keys_computed" {
  description = "(Optional) Configure a deploy key ( SSH key ) that grants access to a single GitHub repository. This key is attached directly to the repository instead of to a personal user account."
  type        = any

  # Example:
  # deploy_keys_computed = [
  #   {
  #     title     = "CI User Deploy Key"
  #     key       = computed.resource
  #     read_only = true
  #   }
  # ]

  default = []
}

variable "projects" {
  description = "(Optional) Create and manage projects for GitHub repository."
  type = list(object({
    name = string
    body = string
  }))

  # Example:
  # projects = [
  #   {
  #     name = "Testproject"
  #     body = "This is a fancy test project for testing"
  #   }
  # ]

  default = []
}

variable "webhooks" {
  description = "(Optional) Configuring webhooks. For details please check: https://www.terraform.io/docs/providers/github/r/repository_webhook.html"
  type        = any

  # We can't use a detailed type specification due to a terraform limitation. However, this might be changed in a future
  # Terraform version. See https://github.com/hashicorp/terraform/issues/19898 and https://github.com/hashicorp/terraform/issues/22449
  #
  # type = list(object({
  #   name         = string
  #   active       = bool
  #   events       = list(string)
  #   url          = string
  #   content_type = string
  #   insecure_ssl = bool
  #   secret       = string
  # }))

  default = []

  # Example:
  # webhooks = [{
  #   active = false
  #   events = ["issues"]
  #   url          = "https://google.de/"
  #   content_type = "form"
  #   insecure_ssl = false
  # }]
}

variable "plaintext_secrets" {
  description = "(Optional) Configuring actions secrets. For details please check: https://www.terraform.io/docs/providers/github/r/actions_secret"
  type        = map(string)

  # Example:
  # plaintext_secrets = {
  #     "MY_SECRET" = "42"
  #     "OWN_TOKEN" = "12345"
  # }

  default = {}
}

variable "encrypted_secrets" {
  description = "(Optional) Configuring encrypted actions secrets. For details please check: https://www.terraform.io/docs/providers/github/r/actions_secret"
  type        = map(string)

  # Example:
  # encrypted_secrets = {
  #     "MY_ENCRYPTED_SECRET" = "MTIzNDU="
  # }

  default = {}
}


variable "autolink_references" {
  description = "(Optional) Configuring autolink references. For details please check: https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_autolink_reference"
  type = list(object({
    key_prefix          = string
    target_url_template = string
  }))

  # Example:
  # autolink_references = [
  #   {
  #     key_prefix          = "TICKET-"
  #     target_url_template = "https://hello.there/TICKET?query=<num>"
  #   }
  # ]

  default = []
}

variable "vulnerability_alerts" {
  type        = bool
  description = "(Optional) Set to `false` to disable security alerts for vulnerable dependencies. Enabling requires alerts to be enabled on the owner level."
  default     = null
}

variable "archive_on_destroy" {
  type        = string
  description = "(Optional) Set to `false` to not archive the repository instead of deleting on destroy."
  default     = true
}

variable "app_installations" {
  type        = set(string)
  description = "(Optional) A list of GitHub App IDs to be installed in this repository."
  default     = []
}

# ------------------------------------------------------------------------------
# MODULE CONFIGURATION PARAMETERS
# These variables are used to configure the module.
# ------------------------------------------------------------------------------

variable "module_depends_on" {
  type        = any
  description = "(Optional) Define resources this module indirectly depends_on."
  default     = []
}
