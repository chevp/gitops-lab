#!/usr/bin/env bash
# 99 – Aufräumen: Test-Pod, Namespace und (nach Rückfrage) Cluster löschen.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud
require_kubectl
require_vars PROJECT_ID CLUSTER_NAME NAMESPACE

kubectl delete pod -n "${NAMESPACE}" hello-test --ignore-not-found
kubectl delete namespace "${NAMESPACE}" --ignore-not-found
ok "Test-Pod und Namespace entfernt."

warn "Der Cluster ${CLUSTER_NAME} verursacht Kosten, solange er läuft."
read -r -p "Cluster jetzt löschen? [y/N] " ans
if [[ "${ans:-N}" =~ ^[Yy]$ ]]; then
  LOC="$(location_flag)"
  info "Lösche Cluster ${CLUSTER_NAME} …"
  gcloud container clusters delete "${CLUSTER_NAME}" ${LOC} \
    --project="${PROJECT_ID}" --quiet
  ok "Cluster gelöscht."
else
  warn "Cluster bleibt bestehen. Manuell: gcloud container clusters delete ${CLUSTER_NAME} $(location_flag) --project=${PROJECT_ID}"
fi
