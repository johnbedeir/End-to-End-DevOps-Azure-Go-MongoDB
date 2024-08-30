# End-to-End-DevOps-Azure-Go-MongoDB

<img src=cover.png>

This project is a complete end-to-end DevOps pipeline to deploy a Go application with a MongoDB database on Azure Kubernetes Service (AKS). It leverages Terraform for infrastructure provisioning, Helm for Kubernetes application management, and ArgoCD for GitOps deployment. The monitoring stack, including Prometheus, Alertmanager, and Grafana, is also deployed using Helm.

## Project Structure

```
.
|
├── Go-app/                     # Go App application files
│   ├── application
│   └── ...                     # Other application files
├── k8s/                        # Deployment scripts
│   ├── app.yml                 # To deploy the application
│   └── database.yml            # To deploy the database
├── terraform/                  # Terraform configuration files
│   ├── provider.tf
│   ├── aks.tf
│   └── ...
├── build.sh.yml                # Automate building infra and deployment
├── destroy.sh.yml              # Automate destroying infra and deployment
└── README.md                   # Project Documentation
```

## Prerequisites

Before running this project, ensure you have the following installed:

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Docker](https://www.docker.com/get-started)

## Infrastructure Provisioning

This project uses Terraform to provision the necessary infrastructure on Azure:

1. **Azure Kubernetes Service (AKS)**: A managed Kubernetes cluster to host your application.
2. **Azure Container Registry (ACR)**: A private registry to store Docker images.
3. **ArgoCD**: A GitOps tool to manage application deployment.
4. **Monitoring Stack**: Prometheus, Alertmanager, and Grafana for monitoring the cluster and applications.

## Deployment

The deployment process is automated using the `build.sh` script. The script performs the following tasks:

1. **Terraform Apply**: Runs `terraform apply` to provision the infrastructure on Azure.
2. **Docker Image Build**: Builds the Docker image for the Go application and pushes it to ACR.
3. **Helm Deployments**: Uses Helm to deploy ArgoCD, Prometheus, Alertmanager, and Grafana on AKS.
4. **Kubernetes Application Deployment**: Deploys the Go application and MongoDB to the AKS cluster.
5. **Retrieve LoadBalancer URL**: Fetches the URL of the LoadBalancer service created in the AKS cluster.

### Running the Script

1. Deploy the entire setup, start by running:

   First step, you need to create a file called `subscription.txt` in the root directory, that contains the **Subscription-ID** of your Azure account, just paste the id in the file, then run the `run_me_first.sh` script.

   ```
   ./run_me_first.sh
   ```

   This script will create a service principal app if it doesn't already exist, the output should look like this:

   `IMPORTANT: Make sure to save the output, you won't be able to get the Client Secret again`

   ```
   Service principal does not exist. Creating a new one...
   Client ID: xxxx-xxxx-xxxx-xxxx-xxxx
   Client Secret: xxxxxxxxxxxxxxxx
   Tenant ID: xxxx-xxxx-xxxx-xxxx-xxxx
   ```

2. Create `terraform.tfvars` inside `terraform` directory with the following values:

   ```
     client_id="xxxx-xxxx-xxxx-xxxx-xxxx"
     client_secret="xxxxxxxxxxxxxxxx"
     subscription_id="xxxx-xxxx-xxxx-xxxx-xxxx"
     tenant_id="xxxx-xxxx-xxxx-xxxx-xxxx"
     location="Azure Region"
   ```

   You can find the `subscription_id` by navigating to the `Azure Portal` then `Subscription`

3. Build the infrastructure and deploy using `build.sh` script:
   ```bash
   ./build.sh
   ```

## Accessing the Application

After the build script is executed, you should see the following:

### Infrastructure output:

```
Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

Outputs:

acr_name = "cluster1devacr"
aks_cluster_location = "azure location"
aks_cluster_name = "cluster-1-dev-aks"
client_id = "xxxxxx-xxxxxx-xxxxxx-xxxxxx-xxxxxx"
kube_config = <sensitive>
principal_id = "xxxxxx-xxxxxx-xxxxxx-xxxxxx-xxxxxx"
tenant_id = "xxxxxx-xxxxxx-xxxxxx-xxxxxx-xxxxxx"
```

### Application Deployment

```
--------------------Deploying App--------------------
deployment.apps/goapp-deploy created
service/goapp created
deployment.apps/db-deploy created
service/mongo-app-service created
persistentvolumeclaim/mongo-pvc created
```

### Retrieving Application URLs

```
----------------------Application URL-----------------------
98.67.222.117:8080

------------------------ArgoCD URL--------------------------
98.67.219.216
-------------------- ArgoCD Credentials---------------------
┌─────────┬───────────────────────────┐
│  USER   │  PASSWORD                 │
├─────────┼───────────────────────────┤
│  admin  │ XXXXAXXXXTXXXpCt          │
└─────────┴───────────────────────────┘

----------------------Alertmanager URL----------------------
98.67.218.6:9093

-----------------------Prometheus URL-----------------------
98.67.219.209:9090

------------------------ Grafana URL------------------------
98.67.218.10
-------------------- Grafana Credentials--------------------
┌───────────────┬─────────────────────────┐
│  USER         │  PASSWORD               │
├───────────────┼─────────────────────────┤
│ admin         │ admin                   │
└───────────────┴─────────────────────────┘
```
