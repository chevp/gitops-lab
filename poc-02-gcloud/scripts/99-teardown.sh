#!/usr/bin/env bash
# 99 – Aufräumen: Registry-Repo löschen. Projekt-Löschung nur nach Rückfrage.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud
require_vars PROJECT_ID REGION AR_REPO

if gcloud artifacts repositories describe "${AR_REPO}" \
     --location="${REGION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  info "Lösche Registry-Repo ${AR_REPO} …"
  gcloud artifacts repositories delete "${AR_REPO}" \
    --location="${REGION}" --project="${PROJECT_ID}" --quiet
  ok "Repo gelöscht."
else
  ok "Registry-Repo ${AR_REPO} existiert nicht (nichts zu tun)."
fi

warn "Das Projekt ${PROJECT_ID} wird NICHT automatisch gelöscht."
warn "Bei Bedarf manuell:  gcloud projects delete ${PROJECT_ID}"
