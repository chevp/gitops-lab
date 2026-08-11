#!/usr/bin/env bash
# 05 – Deployment prüfen: Release-Status, Pods, Service, Rollout.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_helm
require_kubectl
require_vars RELEASE_NAME NAMESPACE

info "Helm-Releases:"
helm list -n "${NAMESPACE}"

info "Rollout-Status:"
kubectl rollout status "deployment/${RELEASE_NAME}" -n "${NAMESPACE}" --timeout=120s || true

info "Pods:"
kubectl get pods -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${RELEASE_NAME}" -o wide

info "Service:"
kubectl get svc -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${RELEASE_NAME}"

cat <<EOF

${RELEASE_NAME} lokal testen (Port-Forward):
  kubectl port-forward -n ${NAMESPACE} svc/${RELEASE_NAME} 8080:80
  → http://localhost:8080/
EOF
ok "Prüfung abgeschlossen."
