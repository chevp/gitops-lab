#!/usr/bin/env bash
# 01 – Authentifizierung: User-Login + Application Default Credentials.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud

if gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
  ok "Aktives Konto: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
else
  info "Interaktiver Login (öffnet Browser) …"
  gcloud auth login
fi

if [[ -f "${HOME}/.config/gcloud/application_default_credentials.json" ]]; then
  ok "Application Default Credentials vorhanden."
else
  info "Application Default Credentials einrichten (öffnet Browser) …"
  gcloud auth application-default login
fi

ok "Authentifizierung abgeschlossen."
