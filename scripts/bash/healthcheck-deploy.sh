#!/usr/bin/env bash
# =============================================================================
# healthcheck-deploy.sh
# Post-deploy health check with automatic rollback for SRE environments
# Usage: bash healthcheck-deploy.sh [NAMESPACE] [DEPLOYMENT]
# =============================================================================

set -euo pipefail

# ─── Config ──────────────────────────────────────────────────────────────────
NAMESPACE="${1:-enterprise-middleware}"
DEPLOYMENT="${2:-nodejs-app}"
MAX_RETRIES=10
RETRY_INTERVAL=10
HEALTH_ENDPOINT="http://localhost/health"
METRICS_ENDPOINT="http://localhost:9090/-/healthy"

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}    $1"; }
log_success() { echo -e "${GREEN}[OK]${NC}      $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}    $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC}   $1"; }

# ─── Functions ───────────────────────────────────────────────────────────────

check_kubectl() {
  if ! command -v kubectl &>/dev/null; then
    log_error "kubectl not found. Please install kubectl."
    exit 1
  fi
  log_success "kubectl found: $(kubectl version --client -o json | python3 -c 'import sys,json; print(json.load(sys.stdin)["clientVersion"]["gitVersion"])' 2>/dev/null || echo 'unknown')"
}

check_namespace() {
  log_info "Checking namespace: $NAMESPACE"
  if kubectl get namespace "$NAMESPACE" &>/dev/null; then
    log_success "Namespace '$NAMESPACE' exists"
  else
    log_error "Namespace '$NAMESPACE' not found"
    exit 1
  fi
}

check_deployment_exists() {
  log_info "Checking deployment: $DEPLOYMENT"
  if kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" &>/dev/null; then
    log_success "Deployment '$DEPLOYMENT' exists"
  else
    log_error "Deployment '$DEPLOYMENT' not found in namespace '$NAMESPACE'"
    exit 1
  fi
}

check_pods_running() {
  log_info "Checking pod health..."
  local attempt=1

  while [ $attempt -le $MAX_RETRIES ]; do
    local total ready
    total=$(kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" \
      -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
    ready=$(kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" \
      -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")

    log_info "Attempt $attempt/$MAX_RETRIES: $ready/$total pods ready"

    if [ "$ready" = "$total" ] && [ "$total" -gt 0 ]; then
      log_success "All $total pods are ready"
      return 0
    fi

    if [ $attempt -lt $MAX_RETRIES ]; then
      log_warn "Pods not fully ready. Retrying in ${RETRY_INTERVAL}s..."
      sleep $RETRY_INTERVAL
    fi
    ((attempt++))
  done

  log_error "Pods did not become ready after $((MAX_RETRIES * RETRY_INTERVAL))s"
  return 1
}

check_pod_restarts() {
  log_info "Checking for pod restart loops..."
  local max_restarts=3

  local restart_count
  restart_count=$(kubectl get pods -n "$NAMESPACE" \
    -l "app=$DEPLOYMENT" \
    -o jsonpath='{range .items[*]}{.status.containerStatuses[0].restartCount}{"\n"}{end}' \
    2>/dev/null | sort -n | tail -1 || echo "0")

  if [ "${restart_count:-0}" -gt $max_restarts ]; then
    log_error "Pod restart count ($restart_count) exceeds threshold ($max_restarts) — possible CrashLoopBackOff"
    kubectl describe pods -n "$NAMESPACE" -l "app=$DEPLOYMENT" | tail -30
    return 1
  fi

  log_success "Pod restarts within acceptable range: $restart_count (max: $max_restarts)"
  return 0
}

check_http_endpoint() {
  local url="$1"
  local name="$2"
  log_info "Checking HTTP endpoint: $name ($url)"

  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" \
    --connect-timeout 5 \
    --max-time 10 \
    "$url" 2>/dev/null || echo "000")

  if [[ "$http_code" =~ ^2[0-9]{2}$ ]]; then
    log_success "$name responded with HTTP $http_code"
    return 0
  else
    log_warn "$name returned HTTP $http_code (endpoint may not be exposed locally)"
    return 0  # Non-fatal in CI; adjust to 'return 1' for strict checks
  fi
}

check_prometheus_targets() {
  log_info "Checking Prometheus scrape targets..."
  local prom_pod
  prom_pod=$(kubectl get pods -n "$NAMESPACE" \
    -l "app=prometheus" \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

  if [ -z "$prom_pod" ]; then
    log_warn "Prometheus pod not found — skipping target check"
    return 0
  fi

  local unhealthy
  unhealthy=$(kubectl exec "$prom_pod" -n "$NAMESPACE" -- \
    wget -qO- 'http://localhost:9090/api/v1/targets' 2>/dev/null | \
    python3 -c "
import sys, json
data = json.load(sys.stdin)
unhealthy = [t['labels']['job'] for t in data.get('data',{}).get('activeTargets',[]) if t['health'] != 'up']
print(len(unhealthy))
" 2>/dev/null || echo "0")

  if [ "${unhealthy:-0}" -gt 0 ]; then
    log_warn "$unhealthy Prometheus targets are DOWN"
  else
    log_success "All Prometheus scrape targets are UP"
  fi
}

rollback() {
  log_error "Health check failed. Initiating rollback..."
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 🔄  ROLLBACK IN PROGRESS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  kubectl rollout undo deployment/"$DEPLOYMENT" -n "$NAMESPACE"

  log_info "Waiting for rollback to stabilize..."
  if kubectl rollout status deployment/"$DEPLOYMENT" \
      -n "$NAMESPACE" \
      --timeout=120s; then
    log_success "Rollback completed successfully"
  else
    log_error "Rollback also failed. Manual intervention required!"
    kubectl get pods -n "$NAMESPACE" -o wide
    exit 2
  fi
}

print_summary() {
  local status="$1"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if [ "$status" = "success" ]; then
    echo -e " ${GREEN}✅  HEALTH CHECK PASSED${NC}"
  else
    echo -e " ${RED}❌  HEALTH CHECK FAILED${NC}"
  fi
  echo "   Namespace:  $NAMESPACE"
  echo "   Deployment: $DEPLOYMENT"
  echo "   Timestamp:  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " 🏥  SRE HEALTH CHECK — middleware-sre-platform"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  FAILED=false

  check_kubectl
  check_namespace
  check_deployment_exists

  check_pods_running        || FAILED=true
  check_pod_restarts        || FAILED=true
  check_http_endpoint "$HEALTH_ENDPOINT" "App health endpoint"
  check_http_endpoint "$METRICS_ENDPOINT" "Prometheus"
  check_prometheus_targets

  if [ "$FAILED" = "true" ]; then
    print_summary "failed"
    rollback
    exit 1
  fi

  print_summary "success"
  exit 0
}

main "$@"
