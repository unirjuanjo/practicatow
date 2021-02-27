## VARIABLES GLOBALES
variable "location" {
  type string
  description = "Región de Azure donde queremos crearnos la infraesturctura"
  default = "West Wurope"
}

variable "azurerm_resource_group.practica_dos" {
  type string
  description = "Región de Azure donde queremos crearnos la infraesturctura"
  default = "West Wurope"
}

## VARIABLE CONTADOR PARA CREAR 3 INTERFACES DE RED Y TRES MÁQUINAS VIRTUALES
variable "num_mv_instancias" {  
  type    = "string"
  default = "2"
}

## VARIABLES CUENTA AZURE QUE SE PEDIRAN POR CONSOLA

variable "azure_client_id" {  
  type = "string"
}

variable "azure_client_secret" {  
  type = "string"
}

variable "azure_subscription_id" {  
  type = "string"
}

variable "azure_tenant_id" {  
  type = "string"
}

## VARIABLES DE LAS MÁQUINAS VIRTUALES
variable "vm_size_mv" {
  type string
  description = "Tamaño máquina virtual por defecto"
  default = "Standard_D1_V1" # 3.5 GB, 1 CPU
} 
