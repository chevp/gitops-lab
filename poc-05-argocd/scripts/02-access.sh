#!/usr/bin/env bash
# 02 – Zugangsdaten anzeigen und Port-Forward auf die Argo-CD-UI starten.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars ARGOCD_NAMESPACE

PW="$(argocd_admin_password || true)"
if [[ -z "${PW}" ]]; then
  warn "Kein 'argocd-initial-admin-secret' gefunden."
  warn "Entweder ist Argo CD noch nicht bereit, oder das Passwort wurde bereits geändert."
else
  cat <<EOF

Argo-CD-Login:
  Benutzer:  admin
  Passwort:  ${PW}

CLI-Login (nach dem Start des Port-Forwards, in einem zweiten Terminal):
  argocd login localhost:8080 --username admin --password '${PW}' --insecure

EOF
fi

info "Starte Port-Forward auf https://localhost:8080  (Strg+C zum Beenden) …"
info "UI:  https://localhost:8080/   (Zertifikatswarnung akzeptieren)"
kubectl port-forward -n "${ARGOCD_NAMESPACE}" svc/argocd-server 8080:443
