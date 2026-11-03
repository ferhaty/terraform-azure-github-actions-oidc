resource "azurerm_user_assigned_identity" "terraform" {
  name                = "store-terraform-${var.environment}"
  location            = azurerm_resource_group.foundation.location
  resource_group_name = azurerm_resource_group.foundation.name
}
resource "azurerm_federated_identity_credential" "github" {
  name                      = "github-${var.environment}"
  user_assigned_identity_id = azurerm_user_assigned_identity.terraform.id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = "repo:${var.github_repository_subject}:environment:${var.environment}"
}
resource "azurerm_role_assignment" "workload" {
  scope                = azurerm_resource_group.workload.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.terraform.principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "state" {
  scope                = azurerm_storage_container.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.terraform.principal_id
  principal_type       = "ServicePrincipal"
}
output "client_id" {
  value = azurerm_user_assigned_identity.terraform.client_id
}
output "tenant_id" {
  value = var.tenant_id
}
output "subscription_id" {
  value = var.subscription_id
}
