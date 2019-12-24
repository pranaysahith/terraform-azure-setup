# Azure Terraform detailed instructions:

1. Terraform needs a Service Principal (client_id and client_secret) which is authorized to create resources in Azure subscription
    
    a. Login to https://portal.azure.com/
    
    b. Go to Azure Active Directory and select `App Registrations` blade
    
    c. Create new registration by giving a display name for the application and click register.
    
    d. Once the app is registered, from the overview of the app make a note of Application (client) ID.
     Click on `Certificates & secrets` blade to generate client secret. 
     Client secret will be used in terraform to authenticate as this application. Use New client secret button to generate a client secret and keep it safe.
    
    e. Make a note of tenant id from overview blade.

2. Give access to create resources for the service principal.

    a. By default a newly created service principal does not have any access. 
    
    b. Contributor access has to be provided on the subscription in which resources needs to be created. Also, make a note of subscription id.
    
    c. From `Access control (IAM)` blade, click `Add` and choose `Add role assignment`. 
    Select `contributor` from dropdown of Role and search by the name of service principal that is created earlier and select the correct service principal.
    Click on Save button.
    
3. explain azure shell
    
    a. Go to https://shell.azure.com/
    
    b. Choose `bash` from the left top dropdown.
    
    c. Use an editor vi or nano to create an empty file - main.tf  
    
    d. 

4. Install Terraform in Azure Shell

    a. Go to terraform downloads page (https://www.terraform.io/downloads.html) and copy 64 bit Linux URL
    
    b. use wget to download the file in azure shell:
        
        wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip
    
    c. unzip the download zip file:
        
        unzip terraform_0.12.18_linux_amd64.zip
        
    d. copy the extracted terraform file to /usr/local/bundle/bin location so that terraform command can be executed from anywhere.
    
        cp terraform /usr/local/bundle/bin
        
5. Explain Terraform 
    
    1. A provider is responsible for understanding API interactions and exposing resources. 
    azurerm provides interface to Azure Resource Manager to create azure resources.
    client_id and client_secret should be set with values obtained in step 1d. 
    tenant_id and subscription_id are obtained from steps 1e and 2b respectively:
        
            provider "azurerm" {
              version = "1.39"
              client_id = var.client_id
              client_secret = var.client_secret
              subscription_id = var.subscription_id
              tenant_id = var.tenant_id
              environment = "public"
            }

    2. Input variables serve as parameters and are generally defined in variables.tf file
    
            variable "client_id" {}
            variable "client_secret" {}
            variable "subscription_id" {}
            variable "tenant_id" {}
            
    3. Create a resource group. Resource group is a collection of resources. 
    Interpolation syntax can be used to create names for resource groups based on 1 or more variables. 
    Its a good practice to keep separate resource group for each environment such as dev, test, perf, prod etc. 
    
            resource "azurerm_resource_group" "rg" {
              location = var.location
              name = "${var.org_name}-${var.env}-rg"
            }

6. Apply terraform configuration

    1. Run `terraform validate` command to validate the syntax in all tf in current directory. Syntax errors are highlighted in the output. 
    2. Run `terraform plan`  command to generate a plan of action. This shows the resources to be added, changed and destroyed.
    3. Once the plan is generated and looks good, run `terraform apply` and pass the variable values when asked.
    
7. Azure Virtual Network (VNet) is the fundamental building block for a private network in Azure.
   VNet enables many types of Azure resources, such as Azure Virtual Machines (VM),
   to securely communicate with each other as well as internet.
   
        resource "azurerm_virtual_network" "vnet" {
          address_space = ["10.0.0.0/16"]
          location = var.location
          name = "${var.org_name}-${var.env}-vnet"
          resource_group_name = azurerm_resource_group.rg.name
        }
 
8. A subnet is a range of IP addresses in the VNet. You can divide a VNet into multiple subnets for organization and security.
   Each NIC in a VM is connected to one subnet in one VNet. NICs connected to subnets (same or different) within a VNet can communicate with each other without any extra configuration.
   The name of the virtual network in which the subnet has to be created should be mentioned using interpolation.

        resource "azurerm_subnet" "subnet" {
          address_prefix = "10.0.0.0/24"
          name = "${var.org_name}-${var.env}-snet"
          resource_group_name = azurerm_resource_group.rg.name
          virtual_network_name = azurerm_virtual_network.vnet.name
        } 

9. security group contains a list of security rules that allow or deny network traffic to resources connected to Azure Virtual Networks.
   security groups can be associated to subnets, classic VMs or network interfaces.

    Create security group:
    
        resource "azurerm_network_security_group" "sg" {
          location = var.location
          name = "${var.org_name}-${var.env}-sg"
          resource_group_name = azurerm_resource_group.rg.name
        }
    
    Create security rules and assign to security group. Here to allows ssh, source and destination port 22 must be allowed.
         
        resource "azurerm_network_security_rule" "srule" {
          access = "allow"
          direction = "Inbound"
          name = "ssh"
          network_security_group_name = "${azurerm_network_security_group.sg.name}"
          priority = 100
          protocol = "tcp"
          source_port_range = "22"
          destination_port_range = "22"
          source_address_prefixes = ["0.0.0.0"]
          destination_address_prefixes = ["0.0.0.0"]
          resource_group_name = "${azurerm_resource_group.rg.name}"
        }
        
    Associate the security group to the subnet
        
        resource "azurerm_subnet_network_security_group_association" "subnet_sg" {
          network_security_group_id = "${azurerm_network_security_group.sg.id}"
          subnet_id = "${azurerm_subnet.subnet.id}"
        }

10. Network interface with public IP. A network interface enables an Azure Virtual Machine to communicate with internet, Azure, and on-premises resources
    A public IP address is needed to communicate with the Ubuntu VM. Create a public IP and assign the id to ip configuration of NIC.
    

        resource "azurerm_network_interface" "nic" {
          location = "${var.location}"
          name = "${var.org_name}-${var.env}-nic"
          resource_group_name = "${azurerm_resource_group.rg.name}"
          ip_configuration {
            name = "ubuntu-vm-ip"
            private_ip_address_allocation = "Dynamic"
            public_ip_address_id = "${azurerm_public_ip.public_ip.id}"
            subnet_id = "${azurerm_subnet.subnet.id}"
          }
        }
        
        resource "azurerm_public_ip" "public_ip" {
          location = var.location
          name = "ubuntu-ip"
          resource_group_name = azurerm_resource_group.rg.name
          allocation_method = "Dynamic"
        }

      
11. To generate a private public key pair, tls provider can be used in terraform.
    A 2048 bit RSA based key pair is generated.

        provider "tls" {}
        resource "tls_private_key" "key" {
          algorithm = "RSA"
          rsa_bits = 2048
        }

    The private key can be saved to local file to use it while connecting to VM.

        resource "local_file" "private_key" {
          filename = "private_key.pem"
          content = "${tls_private_key.key.private_key_pem}"
        }


12. Create an Ubuntu VM with private key authentication.
        
        resource "azurerm_virtual_machine" "ubuntuvm" {
          location = var.location
          name = "ubuntu-vm"
          network_interface_ids = [azurerm_network_interface.nic.id]
          resource_group_name = azurerm_resource_group.rg.name
          vm_size = var.vm_size
          storage_os_disk {
            name              = "vmdist"
            caching           = "ReadWrite"
            create_option     = "FromImage"
            managed_disk_type = "Standard_LRS"
          }
          storage_image_reference {
            publisher = "Canonical"
            offer     = "UbuntuServer"
            sku       = "18.04-LTS"
            version   = "latest"
          }
          os_profile {
            admin_username = var.admin_username
            computer_name = "ubuntu"
          }
          os_profile_linux_config {
            disable_password_authentication = true
            ssh_keys {
              key_data = tls_private_key.key.public_key_openssh
              path = "/home/${var.admin_username}/.ssh/authorized_keys"
            }
          }
        }
 
