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

## Setting Up the CI/CD Pipeline with CircleCI

This guide will walk you through the steps to set up Continuous Integration and Continuous Deployment (CI/CD) for this project using CircleCI.

### 1. Create an Account on CircleCI

1. Visit [CircleCI](https://circleci.com/) and sign up using your GitHub account.
2. Once signed in, you will be prompted to authorize CircleCI to access your GitHub repositories. Grant the necessary permissions to allow CircleCI to integrate with your projects.

### 2. Connect CircleCI to Your GitHub Repository and Create Pipelines

1. After logging in to CircleCI, go to the **Projects** page and find the repository you want to connect.
2. Click on **Set Up Project**.
3. CircleCI will automatically detect the `.circleci/config.yml` file in your repository.
4. To create a pipeline:
   - Navigate to the **Pipelines** section from your project’s settings.
   - Click on **Add Pipeline**.
   - Give the pipeline a name (e.g., "CI/CD Pipeline (dev)" or "CI/CD Pipeline (main)").
   - Select the GitHub App as the **Config Source**.
   - Choose the branch you want this pipeline to track (e.g., `dev`, `main`).
   - Click **Save** to create the pipeline.
5. Repeat the process for any other branches you wish to set up pipelines for.

### 3. Setting Up Triggers for Your Pipelines

1. After creating the pipelines, navigate to the **Triggers** section in your project’s settings.
2. Click on **Add Trigger** to create a new trigger.
3. Name the trigger appropriately (e.g., "Trigger CI/CD (dev)" or "Trigger CI/CD (main)").
4. Select the pipeline that corresponds to this trigger (e.g., choose the "CI/CD Pipeline (dev)" for the `dev` branch).
5. Define the conditions for the trigger, such as triggering on push events or pull requests.
6. Click **Save** to create the trigger.
7. Repeat the process for other branches if necessary.

### 4. Setting Up Environment Variables

To securely pass sensitive information like Azure credentials and Kubernetes configuration to CircleCI, follow these steps:

1. Navigate to your project's **Settings** in CircleCI.
2. Go to the **Environment Variables** section under **Build Settings**.
3. Add the following environment variables with the corresponding values:

   - **`AZURE_CLIENT_ID`**: The client ID of your Azure service principal.
   - **`AZURE_CLIENT_SECRET`**: The client secret of your Azure service principal.
   - **`AZURE_TENANT_ID`**: The tenant ID associated with your Azure service principal.
   - **`ACR_NAME`**: The name of your Azure Container Registry.
   - **`IMAGE_NAME`**: The name you want to give your Docker image.
   - **`KUBECONFIG_CONTENT`**: Base64-encoded content of your Kubernetes `kubeconfig` file.

4. Make sure each variable is correctly configured and matches the values required for your project.

### 5. Push Changes to Trigger the Pipeline

Once everything is set up:

1. Push any changes to your GitHub repository.
2. CircleCI will automatically detect the push and start running the CI/CD pipeline as defined in your `.circleci/config.yml`.
3. You can monitor the progress and results of your builds and deployments directly in the CircleCI dashboard.

<img src=imgs/circleci-1.png>
<img src=imgs/circleci-2.png>

---

## Setting Up Continuous Deployment with ArgoCD

This section will guide you through the process of integrating your GitHub repository with ArgoCD to automate the deployment of your application to a Kubernetes cluster.

### 1. Access ArgoCD

Once ArgoCD has been deployed using Helm with Terraform, you can access the ArgoCD web UI directly using the following URL and credentials:

- **ArgoCD URL**: `ARGO-CD URL`
- **Username**: `admin`
- **Password**: `ARGO-CD PASSWORD`

### 2. Log in to ArgoCD

1. Open your web browser and navigate to the ArgoCD URL provided: [http://98.67.219.216](http://98.67.219.216).
2. Log in using the provided credentials:
   - **Username**: `admin`
   - **Password**: `ARGO-CD PASSWORD`

### 3. Add Your GitHub Repository to ArgoCD

1. **Navigate to Repositories**:

   - Once logged in, click on **Settings** in the left sidebar, and then click on **Repositories**.

2. **Add a New Repository**:
   - Click on the **Connect Repo using HTTPS/SSH** button.
   - **Repository URL**: Enter the URL of your GitHub repository, for example: `https://github.com/your-username/your-repository`.
   - **Type**: Choose the repository type (`Public` or `Private`). If private, you may need to provide SSH credentials or an access token.
   - **Name**: Optionally, give the repository a name.
   - Click **Connect** to add the repository to ArgoCD.

### 4. Create a New Application in ArgoCD

1. **Navigate to Applications**:

   - After adding your repository, go to the **Applications** section from the left sidebar.

2. **Create a New Application**:

   - Click the **New App** button.

3. **Application Configuration**:

   - **Application Name**: Provide a name for your application, e.g., `my-app`.
   - **Project**: Select `default` unless you've set up a custom project.
   - **Sync Policy**: Set to manual or automatic depending on your needs.
   - **Repository URL**: Choose the repository you added earlier.
   - **Path**: Specify the path to the directory where your Kubernetes manifests or Helm chart are located, e.g., `k8s/`.
   - **Cluster**: Choose the cluster where you want to deploy the application (usually the in-cluster Kubernetes context).
   - **Namespace**: Enter the Kubernetes namespace where the application should be deployed, e.g., `default`.

4. **Sync Options**:

   - You can enable auto-sync to automatically deploy changes from the repository to the cluster.
   - Optionally, enable self-heal and prune resources.

5. **Create the Application**:
   - Once all the fields are configured, click **Create** to create the application.

### 5. Sync and Deploy the Application

1. After the application is created, you will be redirected to the application dashboard.
2. If you've set up auto-sync, ArgoCD will automatically deploy the application based on the configurations in the repository.
3. If manual sync is enabled:
   - Click on the **Sync** button to manually trigger the deployment.
   - Monitor the sync status and logs to ensure the application is deployed correctly.
