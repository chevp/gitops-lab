#!/usr/bin/env bash
# 01 – GKE-Cluster erstellen (idempotent).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud
require_vars PROJECT_ID CLUSTER_NAME MACHINE_TYPE NUM_NODES

LOC="$(location_flag)"

if gcloud container clusters describe "${CLUSTER_NAME}" ${LOC} \
     --project="${PROJECT_ID}" >/dev/null 2>&1; then
  ok "Cluster ${CLUSTER_NAME} existiert bereits (${LOC})."
  exit 0
fi

info "Erstelle Cluster ${CLUSTER_NAME} (${LOC}) – das dauert einige Minuten …"
gcloud container clusters create "${CLUSTER_NAME}" \
  --project="${PROJECT_ID}" \
  ${LOC} \
  --machine-type="${MACHINE_TYPE}" \
  --num-nodes="${NUM_NODES}" \
  --release-channel=regular

ok "Cluster erstellt."
