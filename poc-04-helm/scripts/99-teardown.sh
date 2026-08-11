#!/usr/bin/env bash
# 99 – Aufräumen: Helm-Release deinstallieren. Namespace nur nach Rückfrage.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_helm
require_kubectl
require_vars RELEASE_NAME NAMESPACE

if helm status "${RELEASE_NAME}" -n "${NAMESPACE}" >/dev/null 2>&1; then
  info "Deinstalliere Release '${RELEASE_NAME}' …"
  helm uninstall "${RELEASE_NAME}" -n "${NAMESPACE}"
  ok "Release entfernt."
else
  warn "Release '${RELEASE_NAME}' existiert nicht (nichts zu tun)."
fi

read -r -p "Namespace '${NAMESPACE}' ebenfalls löschen? [y/N] " ans
if [[ "${ans:-}" =~ ^[Yy]$ ]]; then
  kubectl delete namespace "${NAMESPACE}" --ignore-not-found
  ok "Namespace gelöscht."
else
  info "Namespace bleibt bestehen."
fi
