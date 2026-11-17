#!/usr/bin/env bash
# 99 – Aufräumen: Application entfernen. Argo CD / Namespaces nur nach Rückfrage.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars APP_NAME ARGOCD_NAMESPACE NAMESPACE

if kubectl -n "${ARGOCD_NAMESPACE}" get application "${APP_NAME}" >/dev/null 2>&1; then
  info "Lösche Application '${APP_NAME}' (Finalizer räumt die App-Ressourcen ab) …"
  kubectl -n "${ARGOCD_NAMESPACE}" delete application "${APP_NAME}" --wait=true
  ok "Application entfernt."
else
  warn "Application '${APP_NAME}' existiert nicht (nichts zu tun)."
fi

read -r -p "Argo CD komplett deinstallieren (Namespace '${ARGOCD_NAMESPACE}')? [y/N] " ans
if [[ "${ans:-}" =~ ^[Yy]$ ]]; then
  kubectl delete namespace "${ARGOCD_NAMESPACE}" --ignore-not-found
  ok "Argo CD entfernt."
else
  info "Argo CD bleibt bestehen."
fi

read -r -p "App-Namespace '${NAMESPACE}' ebenfalls löschen? [y/N] " ans2
if [[ "${ans2:-}" =~ ^[Yy]$ ]]; then
  kubectl delete namespace "${NAMESPACE}" --ignore-not-found
  ok "App-Namespace gelöscht."
else
  info "App-Namespace bleibt bestehen."
fi
