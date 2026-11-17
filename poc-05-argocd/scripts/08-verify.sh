#!/usr/bin/env bash
# 08 – Ergebnis prüfen: Application-Status, deployte Pods, Service.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars APP_NAME ARGOCD_NAMESPACE NAMESPACE

info "Argo-CD-Application:"
kubectl -n "${ARGOCD_NAMESPACE}" get application "${APP_NAME}" \
  -o custom-columns='NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status,REVISION:.status.sync.revision'

if command -v argocd >/dev/null 2>&1 && argocd app get "${APP_NAME}" >/dev/null 2>&1; then
  info "Details (argocd-CLI):"
  argocd app get "${APP_NAME}" || true
fi

info "Pods im Ziel-Namespace '${NAMESPACE}':"
kubectl get pods -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${APP_NAME}" -o wide

info "Service:"
kubectl get svc -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${APP_NAME}"

cat <<EOF

App lokal testen (Port-Forward):
  kubectl port-forward -n ${NAMESPACE} svc/${APP_NAME} 8080:80
  → http://localhost:8080/
EOF
ok "Prüfung abgeschlossen."
