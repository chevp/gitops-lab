#!/usr/bin/env bash
# 02 – Chart installieren bzw. installieren-oder-aktualisieren (idempotent).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_helm
require_kubectl
require_vars RELEASE_NAME NAMESPACE IMAGE_NAME IMAGE_TAG PROJECT_ID REGION AR_REPO

[[ -n "${OPENAI_API_KEY:-}" ]] \
  || die "OPENAI_API_KEY ist leer. Setze: export OPENAI_API_KEY=sk-..."

CHART="$(chart_path)"
REF="$(image_ref)"
REPO="${REF%:*}"

info "Deploye Release '${RELEASE_NAME}' nach Namespace '${NAMESPACE}' …"
helm upgrade --install "${RELEASE_NAME}" "${CHART}" \
  --namespace "${NAMESPACE}" --create-namespace \
  --set image.repository="${REPO}" \
  --set image.tag="${IMAGE_TAG}" \
  --set openai.apiKey="${OPENAI_API_KEY}" \
  --wait --timeout 5m

ok "Deploy abgeschlossen."
info "Status:  helm status ${RELEASE_NAME} -n ${NAMESPACE}"
