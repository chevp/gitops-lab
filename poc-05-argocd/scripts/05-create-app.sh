#!/usr/bin/env bash
# 05 – Argo-CD-Application aus der Vorlage rendern und anwenden (idempotent).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars APP_NAME ARGOCD_NAMESPACE ARGOCD_PROJECT \
  GIT_REPO_URL GIT_TARGET_REVISION CHART_PATH \
  NAMESPACE IMAGE_TAG OPENAI_SECRET_NAME \
  PROJECT_ID REGION AR_REPO IMAGE_NAME
require_cmd envsubst

TMPL="${POC_DIR}/manifests/application.yaml.tmpl"
OUT="${POC_DIR}/manifests/application.rendered.yaml"

# Vollständiges Image-Repo für die Vorlage bereitstellen.
export IMAGE_REPO="$(image_repo)"
export APP_NAME ARGOCD_NAMESPACE ARGOCD_PROJECT \
  GIT_REPO_URL GIT_TARGET_REVISION CHART_PATH \
  NAMESPACE IMAGE_TAG OPENAI_SECRET_NAME

info "Rendere Application-Manifest …"
envsubst < "${TMPL}" > "${OUT}"

info "Wende Application '${APP_NAME}' an …"
kubectl apply -n "${ARGOCD_NAMESPACE}" -f "${OUT}"

ok "Application erstellt. Erste Synchronisation: ./scripts/06-sync.sh"
info "Gerendertes Manifest: ${OUT}"
