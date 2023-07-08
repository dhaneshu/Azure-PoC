# Azure-PoC

This is a PoC project to create an Infrastructure as Code using Terraform and Ansible to build the below resources in Azure. This should be a single package which will do all the listed tasks when triggered.

1. Create a virtual network (VNet) with the CIDR of your choice. 
2. Create an Azure Autoscaling Group (Azure Virtual Machine Scale Sets).
3. Create a Virtual machine and configure it as a web server.
4. Change the default web server TCP port from 80 to TCP 8080.
5. Create an Azure Load Balancer and point the web server to it.
6. Open TCP port 80 on the security group and allow incoming traffic from the world.
7. Create an Azure Active Directory (AD) user and grant them access to only restart the web server.


# How to use it

## Pre-requisites
1. Need an Azure account with Contributor access to the Subscription and User Administrator access in Azure Active Directory

## How to use the package

1. login to your Azure account
2. Create a Storage account manually using the below commands for storing the terraform state

Login to Azure by running 

```
az login
az account set -s <subscription ID>
```

Create a storage account 

```
az group create --name <RG name> --location <location>

az group create --name rg-tfstate --location "East US"

```

Create the Azure storage account

```
az storage account create \
  --name <mystorageaccount> \
  --resource-group <RG name> \
  --location <location> \
  --sku Standard_LRS \
  --kind StorageV2

az storage account create \
  --name sgpoctfstatefile \
  --resource-group rg-tfstate \
  --location "East US" \
  --sku Standard_LRS \
  --kind StorageV2

```

Create the storage container as below

```
az storage container create \
    --account-name <Storage Account Name> \
    --name <container name> 


az storage container create \
    --account-name sgpoctfstatefile \
    --name tfstate

```

3. Update the "backend" section in the [provider.tf](provider.tf) file

4. Update your inputs in the [input.tf](input.tf) file

5. Run ```terraform init``` to initiate it

6. Create a terraform workspace with the name "poc"

```
terraform workspace new poc
terraform workspace select poc
```

7. Run ```terraform plan``` and validate the output
8. Create the resources by running ```terraform apply```



