#!/usr/bin/env bash
# 01 – Argo CD im Cluster installieren (idempotent).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars ARGOCD_NAMESPACE ARGOCD_VERSION

MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

info "Erstelle Namespace '${ARGOCD_NAMESPACE}' …"
kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

info "Installiere Argo CD (${ARGOCD_VERSION}) …"
kubectl apply -n "${ARGOCD_NAMESPACE}" -f "${MANIFEST}"

info "Warte auf den argocd-server Rollout …"
kubectl rollout status deployment/argocd-server -n "${ARGOCD_NAMESPACE}" --timeout=300s

ok "Argo CD installiert. Zugang: ./scripts/02-access.sh"
