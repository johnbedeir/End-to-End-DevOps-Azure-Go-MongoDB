variable "argoworkflows_values" {
  type    = string
  default = <<EOF
controller:
  config:
    containerRuntimeExecutor: pns

server:
  service:
    type: LoadBalancer
    ports:
      - port: 80
        targetPort: 2746
  insecure: true
  extraArgs:
    - --auth-mode=server
    - --auth-mode=client
EOF
}

resource "helm_release" "argoworkflows" {
  name             = "argo-workflows"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-workflows"
  version          = "0.28.1"
  cleanup_on_fail  = true
  namespace        = "argo"
  create_namespace = true

  values = [var.argoworkflows_values]

  depends_on = [azurerm_kubernetes_cluster.aks]
}
