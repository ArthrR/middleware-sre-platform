# Terraform — Platform Infrastructure

Provisions the Kubernetes-native resources for the lab: namespace, resource quota, zero-trust network policies, shared config/secrets, and the `kube-prometheus-stack` Helm release. Targets a local cluster (Minikube, Kind, or Docker Desktop Kubernetes) via the `hashicorp/kubernetes` and `hashicorp/helm` providers — no cloud provider resources are created.

## Usage

```bash
cd terraform
cp variables.tfvars.example terraform.tfvars   # edit as needed, never commit this file
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## What it manages

| Resource | Purpose |
|---|---|
| `kubernetes_namespace.platform` | The `enterprise-middleware` namespace (name configurable via `var.namespace`) |
| `kubernetes_resource_quota.platform` | Caps CPU/memory/pod count for the namespace |
| `kubernetes_network_policy.default_deny` / `allow_internal` | Zero-trust baseline: deny all ingress by default, allow intra-namespace traffic |
| `kubernetes_config_map.platform_config` | Shared env config (log level, health check path, etc.) |
| `kubernetes_secret.db_credentials` | Local-dev DB credentials (use Vault/cloud secrets manager in production) |
| `helm_release.kube_prometheus_stack` | Prometheus + Grafana via the community Helm chart, conditional on `var.enable_monitoring` |

All variables are declared inline in `main.tf` (see the top of the file) — there is no separate `variables.tf`. Defaults and descriptions are documented next to each `variable` block.

## Notes

- No remote state backend is configured by default; the commented-out `backend "s3"` block in `main.tf` shows how to add one for team use.
- This module is deliberately scoped to what a laptop-sized cluster needs. It does not provision cloud infrastructure (EKS/AKS/GKE, VPCs, IAM, GPU node pools) — see `docs/ARCHITECTURE.md` for where that would plug in for a production AI platform deployment.
