#!/bin/bash

# Variables
service_perincipal_name="goapp"
# End of Variables

# Delete the service principal if it exists
sp_id=$(az ad sp list --display-name $service_perincipal_name --query "[0].appId" -o tsv)

if [ -n "$sp_id" ]; then
    echo "Service principal exists. Deleting the service principal..."
    az ad sp delete --id $sp_id || { echo "Failed to delete service principal"; exit 1; }
else
    echo "Service principal does not exist, skipping deletion."
fi



# Build the infrastructure
echo "--------------------Destroying Infrastructure--------------------"
cd terraform || { echo "Terraform directory not found"; exit 1; }
terraform init || { echo "Terraform init failed"; exit 1; }
terraform destroy -auto-approve || { echo "Terraform destroy failed"; exit 1; }
cd ..