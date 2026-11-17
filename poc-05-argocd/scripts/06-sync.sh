#!/usr/bin/env bash
# 06 – Erste, manuelle Synchronisation der Application anstoßen.
# Nutzt die argocd-CLI, wenn eingeloggt; sonst Fallback über kubectl-Annotation.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars APP_NAME ARGOCD_NAMESPACE

if command -v argocd >/dev/null 2>&1 && argocd app get "${APP_NAME}" >/dev/null 2>&1; then
  info "Synchronisiere via argocd-CLI …"
  argocd app sync "${APP_NAME}"
  argocd app wait "${APP_NAME}" --health --timeout 300
else
  warn "argocd-CLI nicht eingeloggt – Fallback über kubectl."
  info "Stoße Sync per Annotation an …"
  kubectl -n "${ARGOCD_NAMESPACE}" annotate application "${APP_NAME}" \
    argocd.argoproj.io/refresh=hard --overwrite
  info "Status beobachten:"
  kubectl -n "${ARGOCD_NAMESPACE}" get application "${APP_NAME}" \
    -o custom-columns='SYNC:.status.sync.status,HEALTH:.status.health.status' -w
fi

ok "Synchronisation angestoßen."
