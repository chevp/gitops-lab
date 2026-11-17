#!/usr/bin/env bash
# 07 – Auto-Sync aktivieren: automated + prune + selfHeal.
# Danach zieht Argo CD jede Git-Änderung selbstständig nach (Basis für PoC 06).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars APP_NAME ARGOCD_NAMESPACE

if command -v argocd >/dev/null 2>&1 && argocd app get "${APP_NAME}" >/dev/null 2>&1; then
  info "Aktiviere Auto-Sync via argocd-CLI …"
  argocd app set "${APP_NAME}" --sync-policy automated --auto-prune --self-heal
else
  warn "argocd-CLI nicht eingeloggt – Fallback über kubectl patch."
  info "Aktiviere Auto-Sync per Merge-Patch …"
  kubectl -n "${ARGOCD_NAMESPACE}" patch application "${APP_NAME}" --type merge -p '{
    "spec": { "syncPolicy": {
      "automated": { "prune": true, "selfHeal": true },
      "syncOptions": ["CreateNamespace=true"]
    } }
  }'
fi

ok "Auto-Sync aktiv (prune + selfHeal)."
