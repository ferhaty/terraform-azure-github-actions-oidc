resource "azurerm_servicebus_namespace" "store" {
  name                = var.namespace_name
  location            = "westeurope"
  resource_group_name = "store-${var.environment}"
  sku                 = "Standard"
  local_auth_enabled  = false
  minimum_tls_version = "1.2"
  tags = {
    Service     = "store"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_servicebus_queue" "orders" {
  name                                 = "order-events-${var.environment}"
  namespace_id                         = azurerm_servicebus_namespace.store.id
  default_message_ttl                  = "P4D"
  lock_duration                        = "PT1M"
  max_delivery_count                   = 10
  dead_lettering_on_message_expiration = true
}
output "queue_id" {
  value = azurerm_servicebus_queue.orders.id
}
