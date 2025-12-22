variable "resource_group_name" {
  description = "Nome do resource group"
  type        = string
  default     = "wso2-rg"
}

variable "location" {
  description = "Região Azure"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}
