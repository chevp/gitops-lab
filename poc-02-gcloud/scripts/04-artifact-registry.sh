#!/usr/bin/env bash
# 04 – Artifact Registry (Docker) anlegen + Docker-Auth einrichten.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud
require_vars PROJECT_ID REGION AR_REPO

if gcloud artifacts repositories describe "${AR_REPO}" \
     --location="${REGION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  ok "Registry-Repo ${AR_REPO} existiert bereits (${REGION})."
else
  info "Erstelle Docker-Repo ${AR_REPO} in ${REGION} …"
  gcloud artifacts repositories create "${AR_REPO}" \
    --repository-format=docker \
    --location="${REGION}" \
    --project="${PROJECT_ID}" \
    --description="GitOps Lab container images"
  ok "Repo erstellt."
fi

info "Richte Docker-Authentifizierung für ${REGION}-docker.pkg.dev ein …"
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

ok "Push-Ziel:"
printf '   %s-docker.pkg.dev/%s/%s/<image>:<tag>\n' "${REGION}" "${PROJECT_ID}" "${AR_REPO}"
