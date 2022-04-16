resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_A2_v2"
  }

  service_principal {
    client_id = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
      network_plugin = "kubenet"
      load_balancer_sku = "standard"
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
        key_data = var.ssh_key
    }
  }

}
