#!/usr/bin/env bash
# 02 – kubectl konfigurieren (kubeconfig-Eintrag für den Cluster holen).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud
require_vars PROJECT_ID CLUSTER_NAME

# gke-gcloud-auth-plugin wird von kubectl gegen GKE benötigt.
if ! command -v gke-gcloud-auth-plugin >/dev/null 2>&1; then
  warn "gke-gcloud-auth-plugin fehlt – installiere via gcloud …"
  gcloud components install gke-gcloud-auth-plugin --quiet \
    || die "Installation fehlgeschlagen. Manuell: gcloud components install gke-gcloud-auth-plugin"
fi

LOC="$(location_flag)"
info "Hole Credentials für ${CLUSTER_NAME} …"
gcloud container clusters get-credentials "${CLUSTER_NAME}" ${LOC} \
  --project="${PROJECT_ID}"

ok "kubeconfig-Kontext: $(kubectl config current-context 2>/dev/null || echo unbekannt)"
