# terraform-azure-setup
1. Download and install terraform of not already present -  https://www.terraform.io/downloads.html
2. Clone this git repository
3. Run `terraform plan`, pass the variable values when asked
4. If plan looks good, run `terraform apply`

## Detailed instructions:

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
    
    b. Contributor access has to be provided on the subscription in which resources needs to be created.
    
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
        
        `wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip`
    
    c. unzip the download zip file:
        
        `unzip terraform_0.12.18_linux_amd64.zip`
        
    d. copy the extracted terraform file to /usr/local/bundle/bin location so that terraform command can be executed from anywhere.
    
        `cp terraform /usr/local/bundle/bin`
        
5. Explain Terraform main.tf
    
    1. A provider is responsible for understanding API interactions and exposing resources:
        `provider "azurerm" {
          version = "1.39"
          client_id = "${var.client_id}"
          client_secret = "${var.client_secret}"
          subscription_id = "${var.subscription_id}"
          tenant_id = "${var.tenant_id}"
          environment = "public"
        }`


6. explain ssh keys
