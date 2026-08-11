#!/usr/bin/env bash
# 03 – Upgrade demonstrieren: neuen Wert setzen (z. B. replicaCount) und
# eine neue Revision erzeugen. Optionales Argument = replicaCount (Default 2).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_helm
require_vars RELEASE_NAME NAMESPACE IMAGE_TAG PROJECT_ID REGION AR_REPO IMAGE_NAME

REPLICAS="${1:-2}"
CHART="$(chart_path)"
REF="$(image_ref)"
REPO="${REF%:*}"

info "Upgrade '${RELEASE_NAME}' → replicaCount=${REPLICAS} …"
helm upgrade "${RELEASE_NAME}" "${CHART}" \
  --namespace "${NAMESPACE}" \
  --reuse-values \
  --set image.repository="${REPO}" \
  --set image.tag="${IMAGE_TAG}" \
  --set replicaCount="${REPLICAS}" \
  --wait --timeout 5m

ok "Upgrade fertig."
info "Historie:  helm history ${RELEASE_NAME} -n ${NAMESPACE}"
