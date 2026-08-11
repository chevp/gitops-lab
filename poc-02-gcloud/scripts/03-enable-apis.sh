#!/usr/bin/env bash
# 03 – Benötigte Google-Cloud-APIs aktivieren.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud
require_vars PROJECT_ID

APIS=(
  container.googleapis.com            # GKE
  artifactregistry.googleapis.com     # Container-Images
  compute.googleapis.com              # Netzwerk/VMs hinter GKE
  cloudresourcemanager.googleapis.com # Projekt-/IAM-Verwaltung
)

info "Aktiviere APIs für ${PROJECT_ID} (kann 1–2 Minuten dauern) …"
gcloud services enable "${APIS[@]}" --project="${PROJECT_ID}"

ok "Aktivierte Dienste:"
gcloud services list --enabled --project="${PROJECT_ID}" \
  --filter="config.name:(container.googleapis.com OR artifactregistry.googleapis.com OR compute.googleapis.com OR cloudresourcemanager.googleapis.com)" \
  --format="table(config.name)"
