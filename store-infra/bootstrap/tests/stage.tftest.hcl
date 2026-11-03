mock_provider "azurerm" {}
run "foundation_stage" {
  command = apply
  variables {
    environment               = "stage"
    subscription_id           = "00000000-0000-0000-0000-000000000002"
    tenant_id                 = "10000000-0000-0000-0000-000000000001"
    state_account_name        = "storestagemock"
    github_repository_subject = "example-org@123/store-infra@456"
  }
  override_resource {
    target = azurerm_resource_group.foundation
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/store-foundation-stage"
    }
  }
  override_resource {
    target = azurerm_resource_group.workload
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/store-stage"
    }
  }
  override_resource {
    target = azurerm_storage_account.state
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/store-foundation-stage/providers/Microsoft.Storage/storageAccounts/storestagemock"
    }
  }
  override_resource {
    target = azurerm_storage_container.state
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/store-foundation-stage/providers/Microsoft.Storage/storageAccounts/storestagemock/blobServices/default/containers/tfstate"
    }
  }
  override_resource {
    target = azurerm_user_assigned_identity.terraform
    values = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/store-foundation-stage/providers/Microsoft.ManagedIdentity/userAssignedIdentities/store-terraform-stage"
      principal_id = "20000000-0000-0000-0000-000000000002"
      client_id    = "30000000-0000-0000-0000-000000000002"
    }
  }
  assert {
    condition     = azurerm_federated_identity_credential.github.subject == "repo:example-org@123/store-infra@456:environment:stage" && azurerm_federated_identity_credential.github.issuer == "https://token.actions.githubusercontent.com" && azurerm_federated_identity_credential.github.audience == tolist(["api://AzureADTokenExchange"])
    error_message = "Trust only the exact repository/environment and Azure token exchange audience."
  }
  assert {
    condition     = azurerm_role_assignment.workload.scope == "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/store-stage" && azurerm_role_assignment.workload.role_definition_name == "Contributor" && azurerm_role_assignment.state.scope == "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/store-foundation-stage/providers/Microsoft.Storage/storageAccounts/storestagemock/blobServices/default/containers/tfstate" && azurerm_role_assignment.state.role_definition_name == "Storage Blob Data Contributor"
    error_message = "Role scopes must remain in this subscription's workload RG and state container."
  }
  assert {
    condition     = azurerm_role_assignment.workload.principal_id == azurerm_role_assignment.state.principal_id && !azurerm_storage_account.state.shared_access_key_enabled && !azurerm_storage_account.state.allow_nested_items_to_be_public && azurerm_storage_account.state.blob_properties[0].versioning_enabled
    error_message = "Use one principal and private versioned state with Shared Key disabled."
  }
}
