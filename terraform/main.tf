# =============================================================================
# ai-platform-lab — Terraform Infrastructure
# Provisions local Kubernetes resources via the kubernetes provider
# Compatible with: Minikube, Kind, Docker Desktop K8s
# =============================================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }
  }

  # Uncomment to use remote state (e.g., Terraform Cloud or S3)
  # backend "s3" {
  #   bucket = "your-tfstate-bucket"
  #   key    = "ai-platform-lab/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# ─── Providers ────────────────────────────────────────────────────────────────

provider "kubernetes" {
  # Uses your current kubeconfig context (Minikube, Kind, Docker Desktop, etc.)
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kube_context
  }
}

# ─── Variables ────────────────────────────────────────────────────────────────

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use (e.g., minikube, docker-desktop)"
  type        = string
  default     = "docker-desktop"
}

variable "namespace" {
  description = "Kubernetes namespace for all platform resources"
  type        = string
  default     = "enterprise-middleware"
}

variable "environment" {
  description = "Environment tag (local, staging, prod)"
  type        = string
  default     = "local"

  validation {
    condition     = contains(["local", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: local, staging, prod."
  }
}

variable "app_replicas" {
  description = "Number of replicas for the Node.js app"
  type        = number
  default     = 2
}

variable "enable_monitoring" {
  description = "Deploy Prometheus + Grafana via Helm"
  type        = bool
  default     = true
}

variable "enable_ai_platform" {
  description = "Deploy the AI platform add-ons (ai-gateway ConfigMap, Qdrant via Helm). Ollama and MLflow stay docker-compose-only — see docs/ARCHITECTURE.md."
  type        = bool
  default     = false
}

# ─── Namespace ────────────────────────────────────────────────────────────────

resource "kubernetes_namespace" "platform" {
  metadata {
    name = var.namespace

    labels = {
      name        = var.namespace
      environment = var.environment
      managed-by  = "terraform"
      project     = "ai-platform-lab"
    }

    annotations = {
      "sre/owner"   = "arthur.oliveiraa254@gmail.com"
      "sre/purpose" = "SRE learning lab — enterprise middleware stack"
    }
  }
}

# ─── Resource Quota (SRE best practice) ─────────────────────────────────────

resource "kubernetes_resource_quota" "platform" {
  metadata {
    name      = "platform-quota"
    namespace = kubernetes_namespace.platform.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "4"
      "requests.memory" = "8Gi"
      "limits.cpu"      = "8"
      "limits.memory"   = "16Gi"
      "pods"            = "30"
    }
  }
}

# ─── Network Policy (zero-trust baseline) ────────────────────────────────────

resource "kubernetes_network_policy" "default_deny" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace.platform.metadata[0].name
  }

  spec {
    pod_selector {} # applies to ALL pods in namespace

    policy_types = ["Ingress"]
    # No ingress rules = deny all by default
    # Specific allow rules are defined per-app below
  }
}

resource "kubernetes_network_policy" "allow_internal" {
  metadata {
    name      = "allow-internal-traffic"
    namespace = kubernetes_namespace.platform.metadata[0].name
  }

  spec {
    pod_selector {} # all pods

    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = var.namespace
          }
        }
      }
    }
  }
}

# ─── ConfigMap: Shared Platform Config ───────────────────────────────────────

resource "kubernetes_config_map" "platform_config" {
  metadata {
    name      = "platform-config"
    namespace = kubernetes_namespace.platform.metadata[0].name
    labels    = { managed-by = "terraform" }
  }

  data = {
    ENVIRONMENT       = var.environment
    LOG_LEVEL         = var.environment == "prod" ? "warn" : "debug"
    METRICS_ENABLED   = "true"
    HEALTH_CHECK_PATH = "/health"
    APP_PORT          = "3000"
  }
}

# ─── Secret: Database Credentials ────────────────────────────────────────────
# In production: use Vault or AWS Secrets Manager instead of Terraform secrets

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.platform.metadata[0].name
    labels    = { managed-by = "terraform" }

    annotations = {
      "sre/rotation-policy" = "90-days"
      "sre/secret-type"     = "database"
    }
  }

  type = "Opaque"

  # base64-encoded default values for local dev
  # Override in CI/CD with: TF_VAR_db_password
  data = {
    POSTGRES_USER     = base64encode("admin")
    POSTGRES_PASSWORD = base64encode("changeme-in-production")
    POSTGRES_DB       = base64encode("middleware_db")
    REDIS_PASSWORD    = base64encode("changeme-in-production")
  }
}

# ─── Monitoring: Prometheus + Grafana via Helm ────────────────────────────────

resource "helm_release" "kube_prometheus_stack" {
  count = var.enable_monitoring ? 1 : 0

  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.platform.metadata[0].name
  version    = "55.5.0"

  set {
    name  = "grafana.adminPassword"
    value = "admin" # Change in production
  }

  set {
    name  = "grafana.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "15d"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }

  # SLO alerting rules
  set {
    name  = "defaultRules.rules.alerting"
    value = "true"
  }

  depends_on = [kubernetes_namespace.platform]
}

# ─── AI Platform: ai-gateway config + Qdrant via Helm ────────────────────────
# Ollama and MLflow are deliberately left out of Terraform/Kubernetes — they're
# heavier/stateful services better suited to docker-compose on a laptop-sized
# cluster. See docs/ARCHITECTURE.md.

resource "kubernetes_config_map" "ai_gateway_config" {
  count = var.enable_ai_platform ? 1 : 0

  metadata {
    name      = "ai-gateway-config"
    namespace = kubernetes_namespace.platform.metadata[0].name
    labels    = { managed-by = "terraform", app = "ai-gateway" }
  }

  data = {
    OLLAMA_BASE_URL    = "http://host.docker.internal:11434"
    OLLAMA_MODEL       = "llama3.2:1b"
    OLLAMA_EMBED_MODEL = "nomic-embed-text"
    QDRANT_URL         = "http://qdrant-service:6333"
    QDRANT_COLLECTION  = "lab-docs"
  }
}

resource "helm_release" "qdrant" {
  count = var.enable_ai_platform ? 1 : 0

  name       = "qdrant"
  repository = "https://qdrant.github.io/qdrant-helm"
  chart      = "qdrant"
  namespace  = kubernetes_namespace.platform.metadata[0].name
  version    = "0.12.5"

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "persistence.size"
    value = "2Gi"
  }

  depends_on = [kubernetes_namespace.platform]
}

# ─── Outputs ─────────────────────────────────────────────────────────────────

output "namespace" {
  description = "Kubernetes namespace for the platform"
  value       = kubernetes_namespace.platform.metadata[0].name
}

output "platform_config_name" {
  description = "Name of the platform ConfigMap"
  value       = kubernetes_config_map.platform_config.metadata[0].name
}

output "monitoring_enabled" {
  description = "Whether monitoring stack is deployed"
  value       = var.enable_monitoring
}

output "ai_platform_enabled" {
  description = "Whether the AI platform add-ons (ai-gateway config, Qdrant) are deployed"
  value       = var.enable_ai_platform
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}
