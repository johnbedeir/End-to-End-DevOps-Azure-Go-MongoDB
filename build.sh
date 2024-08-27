#!/bin/bash

# Variables
subscription_id=$(cat subscription.txt)
cluster_name="cluster-1-dev-aks" # Update this if the cluster name is changed in terraform
Location="Germany West Central"
resource_group="cluster-1-dev-rg"
acr_name="cluster1devacr"
service_perincipal_name="goapp"
image_name="$acr_name.azurecr.io/goapp:latest"
AKS_MANAGED_IDENTITY=$(az aks show --resource-group $resource_group --name $cluster_name --query "identityProfile.kubeletidentity.clientId" -o tsv)
service_name="goapp"
argo_service_name="argocd-server"
alertmanager_service_name="kube-prometheus-stack-alertmanager"
grafana_service_name="kube-prometheus-stack-grafana"
prometheus_service_name="kube-prometheus-stack-prometheus"
namespace="go-survey" # Update this if the namespace is changed in k8s manifests
argo_namespace="argocd"
monitoring_namespace="monitoring"
argo_pass=$(kubectl -n $argo_namespace get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
grafana_user=$(kubectl -n $monitoring_namespace get secret $grafana_service_name -o jsonpath="{.data.admin-user}" | base64 --decode)
grafana_pass=$(kubectl -n $monitoring_namespace get secret $grafana_service_name -o jsonpath="{.data.admin-password}" | base64 --decode)
app_port="8080"
alertmanager_port="9093"
prometheus_port="9090"
# End of Variables

# # Check if the service principal already exists
# sp_exists=$(az ad sp list --display-name $service_perincipal_name --query "[?appDisplayName=='$service_perincipal_name'].appId" -o tsv)

# # If the service principal doesn't exist, create it
# if [ -z "$sp_exists" ]; then
#     echo "Service principal does not exist. Creating a new one..."
#     service_perincipal=$(az ad sp create-for-rbac --name "$service_perincipal_name" --role Contributor --scopes /subscriptions/$subscription_id)

#     # Extract details
#     CLIENT_ID=$(echo $service_perincipal | jq -r .appId)
#     CLIENT_SECRET=$(echo $service_perincipal | jq -r .password)
#     TENANT_ID=$(echo $service_perincipal | jq -r .tenant)

#     echo "Client ID: $CLIENT_ID"
#     echo "Client Secret: $CLIENT_SECRET"
#     echo "Tenant ID: $TENANT_ID"
# else
#     echo "Service principal already exists with App ID: $sp_exists"
# fi

# # Update helm repos
# helm repo update

# # Build the infrastructure
# echo "--------------------Creating AKS & ACR--------------------"
# cd terraform || { echo "Terraform directory not found"; exit 1; }
# terraform init || { echo "Terraform init failed"; exit 1; }
# terraform apply -auto-approve || { echo "Terraform apply failed"; exit 1; }
# cd ..

# # Update kubeconfig
# echo "--------------------Updating Kubeconfig--------------------"
# az aks get-credentials --resource-group $resource_group --name $cluster_name || { echo "Failed to update kubeconfig"; exit 1; }

# # Remove previous Docker images
# echo "--------------------Removing Previous Build--------------------"
# docker rmi -f $image_name || true

# # Build new Docker image with new tag
# echo "--------------------Building New Image--------------------"
# docker build -t $image_name ./Go-app/ || { echo "Docker build failed"; exit 1; }

# # ACR Login
# echo "--------------------Logging into ACR--------------------"
# az acr login --name $acr_name || { echo "ACR login failed"; exit 1; }

# # Push the latest build to ACR
# echo "--------------------Pushing Docker Image--------------------"
# docker push $image_name || { echo "Docker push failed"; exit 1; }

# # Create namespace
# echo "--------------------Creating Namespace--------------------"
# kubectl create ns $namespace || true

# az role assignment create --assignee $AKS_MANAGED_IDENTITY --scope $(az acr show --name $acr_name --resource-group $resource_group --query id -o tsv) --role AcrPull

# # Deploy the application
# echo "--------------------Deploying App--------------------"
# kubectl apply -n $namespace -f k8s || { echo "App deployment failed"; exit 1; }

# # Wait for application pods to be running
# echo "--------------------Waiting for App Pods to be Running--------------------"
# kubectl wait --for=condition=ready pod -l app=$service_name -n $namespace --timeout=120s || { echo "Pods are not ready"; exit 1; }

# Get LoadBalancer
echo "--------------------Retrieving App URL--------------------"
echo "Port=$app_port"
kubectl get svc $service_name -n $namespace -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || { echo "Failed to retrieve service IP"; exit 1; }

echo ""

echo "--------------------Retrieving ArgoCD URL--------------------"
kubectl get svc $argo_service_name -n $argo_namespace -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || { echo "Failed to retrieve service IP"; exit 1; }

echo ""

echo "-------------------- ArgoCD Credentials--------------------"
echo "┌─────────┬───────────────────────────┐"
echo "│  USER   │  PASSWORD                 │"
echo "├─────────┼───────────────────────────┤"
echo "│  admin  │ $argo_pass          │"
echo "└─────────┴───────────────────────────┘"

echo ""

echo "--------------------Retrieving Alertmanager URL--------------------"
echo "Port=$alertmanager_port"
kubectl get svc $alertmanager_service_name -n $monitoring_namespace -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || { echo "Failed to retrieve service IP"; exit 1; }

echo ""

echo "--------------------Retrieving Prometheus URL--------------------"
echo "Port=$prometheus_port"
kubectl get svc $prometheus_service_name -n $monitoring_namespace -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || { echo "Failed to retrieve service IP"; exit 1; }

echo ""

echo "--------------------Retrieving Grafana URL--------------------"
kubectl get svc $grafana_service_name -n $monitoring_namespace -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || { echo "Failed to retrieve service IP"; exit 1; }

echo ""

echo "-------------------- Grafana Credentials--------------------"
echo "┌───────────────┬─────────────────────────┐"
echo "│  USER         │  PASSWORD               │"
echo "├───────────────┼─────────────────────────┤"
echo "│ $grafana_user         │ $grafana_pass                   │"
echo "└───────────────┴─────────────────────────┘"