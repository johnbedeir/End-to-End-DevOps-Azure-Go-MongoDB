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

To deploy the entire setup, simply run the `build.sh` script:

```bash
./build.sh
```
