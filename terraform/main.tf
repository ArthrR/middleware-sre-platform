terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "wso2_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_group" "wso2_api_manager" {
  name                = "wso2-api-manager"
  location            = azurerm_resource_group.wso2_rg.location
  resource_group_name = azurerm_resource_group.wso2_rg.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "wso2-api-manager"

  container {
    name   = "wso2am"
    image  = "wso2/wso2am:4.2.0"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 8280
      protocol = "TCP"
    }

    ports {
      port     = 8243
      protocol = "TCP"
    }

    environment_variables = {
      WSO2_SERVER_PROFILE = "api-manager"
    }
  }

  tags = {
    Environment = "Development"
    Project     = "WSO2"
    ManagedBy   = "Terraform"
  }
}

output "api_manager_url" {
  value       = "http://${azurerm_container_group.wso2_api_manager.fqdn}:8280"
  description = "URL do API Manager"
}
