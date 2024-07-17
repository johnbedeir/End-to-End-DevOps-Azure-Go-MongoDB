data "azuread_service_principal" "aks" {
  application_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
}

resource "azurerm_role_assignment" "aks_contributor" {
  scope                = azurerm_resource_group.aks.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}


resource "azurerm_resource_group" "aks" {
  name     = "${var.name_prefix}-${var.environment}-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name_prefix}-${var.environment}-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "${var.name_prefix}-${var.environment}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.private_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    service_cidr       = "10.3.0.0/16"
    dns_service_ip     = "10.3.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }
}

resource "random_shuffle" "availability_zones" {
  input = ["1", "2", "3"]
  result_count = 1
}

resource "azurerm_kubernetes_cluster_node_pool" "primary_nodes" {
  name                = "primarynp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size             = "Standard_DS2_v2"
  node_count          = 3
  vnet_subnet_id      = azurerm_subnet.private_subnet.id

  enable_auto_scaling = true
  min_count           = 3
  max_count           = 5
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.36.0"
  namespace  = "kube-system"

  set {
    name  = "cloudProvider"
    value = "azure"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }
  
  set {
    name  = "azureClientID"
    value = data.azuread_service_principal.aks.object_id
  }

  set {
    name  = "azureResourceGroup"
    value = azurerm_resource_group.aks.name
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = azurerm_kubernetes_cluster.aks.name
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }

  set {
    name  = "extraArgs.scale-down-enabled"
    value = "true"
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "5m"
  }

  set {
    name  = "livenessProbe.initialDelaySeconds"
    value = "60"
  }
}
