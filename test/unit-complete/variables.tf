variable "name" {
  description = "The name of the created repository."
  type        = string
  default     = "test-public-repository-complete-example-A"
}

variable "description" {
  description = "The description of the created repository."
  type        = string
  default     = "A public repository created with terraform to test the terraform-github-repository module."
}

variable "delete_branch_on_merge" {
  description = "Whether or not to delete the merged branch after merging a pull request."
  type        = bool
  default     = true
}

variable "url" {
  description = "The url of the created repository."
  type        = string
  default     = "https://github.com/mineiros-io"
}

variable "has_issues" {
  description = "Set to true to enable the GitHub Issues features on the repository."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Set to true to enable the GitHub Projects features on the repository."
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Set to true to enable the GitHub Wiki features on the repository."
  type        = bool
  default     = true
}

variable "is_template" {
  description = "Whether or not to tell GitHub that this is a template repository. ( Default: false)"
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "Set to false to disable merge commits on the repository."
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Set to true to enable squash merges on the repository."
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Set to true to enable rebase merges on the repository."
  type        = bool
  default     = true
}

variable "allow_auto_merge" {
  description = "Set to true to allow auto-merging pull requests on the repository."
  type        = bool
  default     = true
}


variable "has_downloads" {
  description = "Set to true to enable the (deprecated) downloads features on the repository."
  type        = bool
  default     = false
}

variable "auto_init" {
  description = "Wether or not to produce an initial commit in the repository."
  type        = bool
  default     = true
}

variable "gitignore_template" {
  description = "Use the name of the template without the extension. For example, Haskell. Available templates: https://github.com/github/gitignore"
  type        = string
  default     = "Terraform"
}

variable "license_template" {
  description = "Use the name of the template without the extension. For example, 'mit' or 'mpl-2.0'. Available licences: https://github.com/github/choosealicense.com/tree/gh-pages/_licenses"
  type        = string
  default     = "mit"
}

variable "projects" {
  description = "A list of projects to create."
  type = list(object({
    name = string,
    body = string
  }))
  default = []
}

variable "issue_labels" {
  description = "A list of issue labels to create."
  type = list(object({
    name        = string,
    description = string,
    color       = string
  }))
  default = [
    {
      name        = "WIP"
      description = "Work in Progress..."
      color       = "d6c860"
    },
    {
      name        = "another-label"
      description = "This is a lable created by Terraform..."
      color       = "1dc34f"
    }
  ]
}

variable "topics" {
  description = "The list of topics of the repository."
  type        = list(string)
  default     = ["terraform", "integration-test"]
}

variable "team_name" {
  description = "The name of the created team."
  type        = string
  default     = "test-public-repository-complete-example"
}

variable "team_description" {
  description = "The description of the created team."
  type        = string
  default     = "A secret team created with terraform to test the terraformn-github-repository module."
}

variable "team_user" {
  description = "The user that should be added to the created team."
  type        = string
  default     = "kevcube"
}

variable "repository_defaults" {
  description = "A map of default settings that can be applied to a repository."
  type        = any
  default = {
    homepage_url       = "https://github.com/mineiros-io"
    visibility         = "private"
    allow_merge_commit = true
    gitignore_template = "Terraform"
    license_template   = "mit"
    topics             = ["terraform", "integration-test"]
  }
}

variable "repository_with_defaults_name" {
  description = "The name of the created repository that has default settings attached to it."
  type        = string
  default     = "test-public-repository-complete-example-B"
}

variable "repository_with_defaults_description" {
  description = "The description of the created repository that has default settings attached to it."
  type        = string
  default     = "A public repository created with terraform to test the terraform-github-repository module."
}

variable "secret_name" {
  description = "The name of the secret."
  type        = string
  default     = "MYSECRET"
}

variable "secret_text" {
  description = "Secret value in plain text."
  type        = string
  default     = "42"
}

variable "encrypted_secret_name" {
  description = "The name of the secret."
  type        = string
  default     = "ENCRYPTEDSECRET"
}

variable "encrypted_secret_text" {
  description = "Secret value in Base64 format."
  type        = string
  default     = "NDI="
}

variable "webhook_url" {
  description = "Send events to this URL"
  type        = string
  default     = "https://example.com/events"
}

variable "webhook_content_type" {
  description = "Use this content-type in the webhook"
  type        = string
  default     = "application/json"
}

variable "webhook_insecure_ssl" {
  description = "Configure TLS encryption on the webhook"
  type        = bool
  default     = true
}

variable "webhook_secret" {
  description = "The shared secret for the webhook"
  type        = string
  default     = "correct horse battery staple"
}

variable "webhook_active" {
  description = "Indicate if the webhook should receive events"
  type        = bool
  default     = true
}

variable "webhook_events" {
  description = "The events which will trigger this webhook"
  type        = list(string)
  default     = ["issues"]
}

variable "autolink_references" {
  description = "A list of autolink references"
  type = list(object({
    key_prefix          = string
    target_url_template = string
  }))

  default = [{
    key_prefix          = "TICKET-"
    target_url_template = "https://hello.there/TICKET?query=<num>"
  }]
}

variable "app_installations" {
  type        = set(string)
  description = "A list of GitHub App IDs to be installed in this repository."
  default     = []
}
