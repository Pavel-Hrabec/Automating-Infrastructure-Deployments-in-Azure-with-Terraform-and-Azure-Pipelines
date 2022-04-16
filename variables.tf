variable "project_name" {
  type        = string
  description = "Name of the resource group for this project"
  default     = "terraform"
}

variable "location" {
  type        = string
  description = "Azure region location of Virtual Network"
  default     = "eastus"

}

variable "spokes" {
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