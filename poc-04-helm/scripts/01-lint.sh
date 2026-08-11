#!/usr/bin/env bash
# 01 – Chart validieren: helm lint + Templates rendern (kein Cluster nötig).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_helm
require_vars IMAGE_NAME IMAGE_TAG PROJECT_ID REGION AR_REPO

CHART="$(chart_path)"
REF="$(image_ref)"
REPO="${REF%:*}"

info "helm lint …"
helm lint "${CHART}" \
  --set image.repository="${REPO}" \
  --set image.tag="${IMAGE_TAG}"

info "helm template (Vorschau) …"
helm template "${RELEASE_NAME}" "${CHART}" \
  --set image.repository="${REPO}" \
  --set image.tag="${IMAGE_TAG}" \
  --set openai.apiKey="dummy-for-render" >/dev/null

ok "Chart ist valide."
