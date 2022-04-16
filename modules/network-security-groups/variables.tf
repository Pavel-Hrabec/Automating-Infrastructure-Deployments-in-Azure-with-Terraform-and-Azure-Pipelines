variable "nsgname" {
    type = string
    description = "Name of network security group"
}
variable "rgname" {
    type = string
    description = "Name of resource group"
}
variable "location" {
    type = string
    description = "Azure location"
    default = "eastus"
}

variable "inbound_rules" {
  type = map
  description = "A map of allowed inbound ports and their priority value"
  default = {
    110 = 80
    120 = 443
    130 = 8080
  }
}
