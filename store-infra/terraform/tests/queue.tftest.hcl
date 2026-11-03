mock_provider "azurerm" {
  mock_resource "azurerm_servicebus_namespace" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/mock/providers/Microsoft.ServiceBus/namespaces/mock-namespace"
    }
  }
}
run "queue_dev" {
  command = plan
  variables {
    environment    = "dev"
    namespace_name = "store-dev-mock"
  }
  assert {
    condition     = azurerm_servicebus_namespace.store.resource_group_name == "store-dev" && azurerm_servicebus_queue.orders.name == "order-events-dev"
    error_message = "Workload and queue must belong to the selected environment."
  }
  assert {
    condition     = !azurerm_servicebus_namespace.store.local_auth_enabled && azurerm_servicebus_queue.orders.default_message_ttl == "P4D" && azurerm_servicebus_queue.orders.lock_duration == "PT1M" && azurerm_servicebus_queue.orders.max_delivery_count == 10 && azurerm_servicebus_queue.orders.dead_lettering_on_message_expiration
    error_message = "Keep Entra authentication and the intended message lifecycle settings."
  }
}
run "queue_stage" {
  command = plan
  variables {
    environment    = "stage"
    namespace_name = "store-stage-mock"
  }
  assert {
    condition     = azurerm_servicebus_namespace.store.resource_group_name == "store-stage" && azurerm_servicebus_queue.orders.name == "order-events-stage"
    error_message = "Workload and queue must belong to the selected environment."
  }
  assert {
    condition     = !azurerm_servicebus_namespace.store.local_auth_enabled && azurerm_servicebus_queue.orders.default_message_ttl == "P4D" && azurerm_servicebus_queue.orders.lock_duration == "PT1M" && azurerm_servicebus_queue.orders.max_delivery_count == 10 && azurerm_servicebus_queue.orders.dead_lettering_on_message_expiration
    error_message = "Keep Entra authentication and the intended message lifecycle settings."
  }
}
run "queue_production" {
  command = plan
  variables {
    environment    = "production"
    namespace_name = "store-production-mock"
  }
  assert {
    condition     = azurerm_servicebus_namespace.store.resource_group_name == "store-production" && azurerm_servicebus_queue.orders.name == "order-events-production"
    error_message = "Workload and queue must belong to the selected environment."
  }
  assert {
    condition     = !azurerm_servicebus_namespace.store.local_auth_enabled && azurerm_servicebus_queue.orders.default_message_ttl == "P4D" && azurerm_servicebus_queue.orders.lock_duration == "PT1M" && azurerm_servicebus_queue.orders.max_delivery_count == 10 && azurerm_servicebus_queue.orders.dead_lettering_on_message_expiration
    error_message = "Keep Entra authentication and the intended message lifecycle settings."
  }
}
