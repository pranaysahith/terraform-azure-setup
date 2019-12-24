# terraform-azure-setup
1. Download and install terraform of not already present -  https://www.terraform.io/downloads.html
2. Clone this git repository
3. Run `terraform plan`, pass the variable values when asked
4. If plan looks good, run `terraform apply`

## Detailed instructions:

2. Terraform needs a Service Principal (client_id and client_secret) which is authorized to create resources in Azure subscription
    
    a. Login to https://portal.azure.com/
    
    b. Go to Azure Active Directory and select `App Registrations` blade
    
    c. Create new registration by giving a display name for the application and click register.
    
    d. Once the app is registered, from the overview of the app make a note of Application (client) ID.
     Click on `Certificates & secrets` blade to generate client secret. 
     Client secret will be used in terraform to authenticate as this application. Use New client secret button to generate a client secret and keep it safe.
    
    e. Make a note of tenant id from overview blade.

3. Give access to create resources for the service principal.

    a. By default a newly created service principal does not have any access. 
    
    b. Contributor access has to be provided on the subscription in which resources needs to be created.
    
    c. From `Access control (IAM)` blade, click `Add` and choose `Add role assignment`. 
    Select `contributor` from dropdown of Role and search by the name of service principal that is created earlier and select the correct service principal.
    Click on Save button.
    
0. explain azure shell
    
    a. Go to https://shell.azure.com/
    
    b. Choose `bash` from the left top dropdown.
    
    c.  

3. Explain terraform installation and execution
1. Explain Terraform main.tf
4. explain ssh keys
