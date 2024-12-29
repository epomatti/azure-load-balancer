### General
subscription_id                 = "00000000-0000-0000-0000-000000000000"
allowed_source_address_prefixes = ["1.2.3.4/32"]
location                        = "eastus2"

### Virtual Machine
vm_size            = "Standard_B2ts_v2"
vm_admin_username  = "azureuser"
vm_public_key_path = ".keys/temp_rsa.pub"
vm_image_publisher = "Canonical"
vm_image_offer     = "ubuntu-24_04-lts"
vm_image_sku       = "server"
vm_image_version   = "latest"
