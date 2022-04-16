variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "rg-cluster"
}

variable "location" {
  description = "The location/region to keep all your cluster resources"
  default     = "eastus"
}

variable "aks_name" {
  description = "Name of AKS cluster"
  default     = "terraform-automation-aks"
}

variable "dns_prefix" {
  description = "Name of DNS"
  default     = "terraform-automation-aks"
}

variable "kubernetes_version" {
  description = "Verison of kubernetes to run cluster"
  default     = "1.23.3"
}

variable "client_id" {
  description = "Credentials for kubernetes"
}

variable "client_secret" {
  description = "Credentials for kubernetes"
}

variable "ssh_key" {
  description = "ssh key for linux deployment"
}