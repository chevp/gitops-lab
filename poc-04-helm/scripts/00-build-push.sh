#!/usr/bin/env bash
# 00 – App-Image bauen und in die Artifact Registry pushen (optional).
# Nutzt das Dockerfile in APP_DIR (PoC 01). Für rein lokales Chart-Üben
# (helm lint/template) nicht nötig – erst für ein echtes Deploy auf GKE.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_docker
require_gcloud
require_vars PROJECT_ID REGION AR_REPO IMAGE_NAME IMAGE_TAG APP_DIR

APP_PATH="$(cd "${POC_DIR}/${APP_DIR}" 2>/dev/null && pwd)" \
  || die "APP_DIR ${APP_DIR} nicht gefunden."
[[ -f "${APP_PATH}/Dockerfile" ]] || die "Kein Dockerfile in ${APP_PATH}."

REF="$(image_ref)"

info "Docker-Auth für ${REGION}-docker.pkg.dev einrichten …"
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

info "Baue Image ${REF} (Kontext: ${APP_PATH}) …"
docker build --platform linux/amd64 -t "${REF}" "${APP_PATH}"

info "Pushe ${REF} …"
docker push "${REF}"

ok "Image verfügbar: ${REF}"
