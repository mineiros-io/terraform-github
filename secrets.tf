# ---------------------------------------------------------------------------------------------------------------------
# Action Secrets
# ---------------------------------------------------------------------------------------------------------------------

resource "github_actions_secret" "plaintext_repository_secret" {
  for_each = var.plaintext_secrets

  repository      = github_repository.repository.name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_actions_secret" "repository_secret" {
  for_each = var.encrypted_secrets

  repository      = github_repository.repository.name
  secret_name     = each.key
  encrypted_value = each.value.encrypted
}
