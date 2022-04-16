terraform {
  backend "azure" {
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {

  name     = "RG-${var.project_name}"
  location = var.location
}

# Create hub Virtual Network
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "VNet-${var.project_name}-hub"
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Create subnets for Hub and Spoke topology
  subnet {
    name           = "AzureBastionSubnet"
    address_prefix = "10.100.0.0/24"
  }

  subnet {
    name           = "AzureFirewallSubnet"
    address_prefix = "10.100.1.0/24"
  }

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.100.2.0/24"
  } 
}

# Create spoke Virtual Networks
resource "azurerm_virtual_network" "spoke_vnet" {
  count = var.spokes

  name                = "VNet-${var.project_name}-spoke${count.index}"
  address_space       = ["10.${count.index}.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  subnet {
    name           = "resource${count.index}"
    address_prefix = "10.${count.index}.0.0/24"
    security_group = module.nsg.nsg_id
  }
}

# Hub Network Peering
 resource "azurerm_virtual_network_peering" "hub_peer" {
   for_each = { for v in azurerm_virtual_network.spoke_vnet : v.name => v.id } # looping through spoke V-Nets and creating a map with name and resource ID

   name                      = "peer-hub-to-${each.key}" # key passed from created map in for each loop
   resource_group_name       = azurerm_resource_group.rg.name
   virtual_network_name      = azurerm_virtual_network.hub_vnet.name
   remote_virtual_network_id = each.value # value passed from created map in for each loop
 }

 # Peering
 resource "azurerm_virtual_network_peering" "spoke_peer" {
   for_each = { for v in azurerm_virtual_network.spoke_vnet : v.name => v.id }

   name                      = "peer-${each.key}-to-hub"
   resource_group_name       = azurerm_resource_group.rg.name
   virtual_network_name      = each.key
   remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
 }

 # Create Network Security Group
 module "nsg" {
   source = "./modules/network-security-groups"

   nsgname = "nsg-hub_and_spoke"
   rgname = azurerm_resource_group.rg.name
   location = azurerm_resource_group.rg.location
 }

# Create Storage Account 
module "storage" {
  source = "./modules/storage-account"

  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  storage_account_name = "terr-1278-auto-45-cz"
  skuname = "Standard_LRS"
  create_resource_group = false

  containers_list = [
    { name = "publicapp478844cz", access_type = "blob" },
    { name = "privatetest478844cz", access_type = "private" }
  ]

  tags = {
    ProjectName  = var.project_name
    Env          = "dev"
  }

  enable_advanced_threat_protection = false
  depends_on = [azurerm_resource_group.rg]
}

# Create Kubernetes Cluster
module "cluster" {
  source              = "./modules/cluster"
  client_id           = var.client_id
  client_secret       = var.client_secret
  ssh_key             = var.ssh_key
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location 
  depends_on          = [azurerm_resource_group.rg]
}

module "k8s" {
  source                = "./modules/k8s/"
  host                  = "${module.cluster.host}"
  client_certificate    = "${base64decode(module.cluster.client_certificate)}"
  client_key            = "${base64decode(module.cluster.client_key)}"
  cluster_ca_certificate= "${base64decode(module.cluster.cluster_ca_certificate)}"
}