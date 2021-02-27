# Definiciones de recursos para su infraestructura con TERRAFORM

########################## PROVIDER ######################################
# En la sección provider se indica a Terraform que utilice un proveedor de Azure: subscription_id, client_id, client_secret y tenant_id
terraform {
   required_providers {
     azurerm = {
       source = "hashicorp/azurerm"
      vwersion = "=2.46.1"
   }
  }
}
provider "azurerm" {  
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  subscription_id = "${var.azure_subscription_id}"
  tenant_id       = "${var.azure_tenant_id}"
}

#################  RESOURCE GROUP  ####################################
# Se crea el grupo de recursos 
resource "azurerm_resource_group" "resource_group" {
    name     = "unir_resource_group"
    location = var.location

    tags = {
        environment = "unir_practica_2"
    }
}

############################# RED PRIVADA: RED VIRTUAL Y SUBRED ######################################
# Creación de una red virtual y subredes
resource "azurerm_virtual_network" "virtual_network" {
    name                = "unir_virtual_network"
    address_space       = ["10.0.0.0/16"]
    location            = azure_resource_group.resource_group.location
    resource_group_name = azure_resource_group.resource_group.name

    tags = {
        environment = "unir_practica_2"
    }
}

resource "azurerm_subnet" "subnet" {
    name                 = "unir_subnet"
    resource_group_name  = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    address_prefixes       = ["10.0.2.0/24"]
  
      tags = {
        environment = "unir_practica_2"
    }
}


########################## GRUPO DE SEGURIDAD DE RED #########################################
# Creación de un grupo de seguridad de red
resource "azurerm_network_security_group" "network_security_group" {
    name                = "unir_network_security_group"
    location            = azure_resource_group.resource_group.location
    resource_group_name = azurerm_resource_group.resource_group.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "unir_practica_2"
    }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "network_interface_security_group_association" {
    network_interface_id      = azurerm_network_interface.network_interface.id
    network_security_group_id = azurerm_network_security_group.network_security_group.id
  

######################## IP PUBLICA ###################################

# Creación de una dirección IP pública
resource "azurerm_public_ip" "public_ip" {
    name                         = "unir_public_ip"
    location                     = azure_resource_group.resource_group.location
    resource_group_name          = azurerm_resource_group.resource_group.name
    allocation_method            = "Dynamic"

   tags = {
        environment = "unir_practica_2"
   }
}
  
############################# TARJETA DE RED ######################################
# Creación de una tarjeta de interfaz de red virtual
resource "azurerm_network_interface" "network_interface" {
    count                       = "${var.vm}"
    name                        = "unir_network_interface"
    location                    = azure_resource_group.rg.location
    resource_group_name         = azure_resource_group.rg.name

    ip_configuration {
        name                          = "myNicConfiguration_01"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "unir_practica_2"
    }
}


####################### CRECION DE MAQUINAS VIRTUALES #############################
# El último paso es crear una máquina virtual y usar todos los recursos creados. En la siguiente sección se crea una máquina virtual llamada myVM 
# y se asocia una NIC virtual llamada myNIC. Se usa la imagen Ubuntu 18.04-LTS más reciente y se crea un usuario llamado azureuser con la autenticación
# de contraseña deshabilitada.
# Los datos de la clave SSH se proporcionan en la sección ssh_keys. Proporcione una clave SSH pública en el campo key_data.
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }


#####################################################################################

# Creación de una cuenta de almacenamiento para el diagnóstico

# Para almacenar el diagnóstico de arranque para una máquina virtual, se necesita una cuenta de almacenamiento. Estos diagnósticos de arranque
# pueden ayudarle a solucionar problemas y a supervisar el estado de la máquina virtual. La cuenta de almacenamiento que se crea solo sirve 
# para almacenar datos de diagnóstico de arranque. Como las cuentas de almacenamiento deben tener un nombre único, con la siguiente sección se 
# genera un texto aleatorio
# resource "random_id" "randomId" {
#     keepers = {
#         # Generate a new ID only when a new resource group is defined
#         resource_group = azurerm_resource_group.myterraformgroup.name
#     }

#     byte_length = 8
# }

# Ahora puede crear una cuenta de almacenamiento. Con la siguiente sección se crea una cuenta de almacenamiento,
# con el nombre según el texto aleatorio generado en el paso anterior:
# resource "azurerm_storage_account" "mystorageaccount" {
#     name                        = "diag${random_id.randomId.hex}"
#     resource_group_name         = azurerm_resource_group.myterraformgroup.name
#     location                    = "eastus"
#     account_replication_type    = "LRS"
#     account_tier                = "Standard"

#     tags = {
#         environment = "Terraform Demo"
#     }
# }

#####################################################################################
# El último paso es crear una máquina virtual y usar todos los recursos creados. En la siguiente sección se crea una máquina virtual llamada myVM 
# y se asocia una NIC virtual llamada myNIC. Se usa la imagen Ubuntu 18.04-LTS más reciente y se crea un usuario llamado azureuser con la autenticación
# de contraseña deshabilitada.
# Los datos de la clave SSH se proporcionan en la sección ssh_keys. Proporcione una clave SSH pública en el campo key_data.
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = tls_private_key.example_ssh.private_key_pem }

resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}
