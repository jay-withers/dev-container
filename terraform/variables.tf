variable "name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region where the resource group will be created (e.g. 'uksouth', 'eastus')."
  type        = string
}

variable "tags" {
  description = "Map of tags to assign to the resource group."
  type        = map(string)
  default     = {}
}
