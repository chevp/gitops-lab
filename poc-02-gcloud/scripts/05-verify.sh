#!/usr/bin/env bash
# 05 – Zustand prüfen (Definition of Done für PoC 02).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud
require_vars PROJECT_ID REGION AR_REPO

info "Aktives Konto:"
gcloud auth list --filter=status:ACTIVE --format="value(account)" || warn "kein aktives Konto"

info "Aktive Konfiguration:"
gcloud config list --format="table(section, name, value)" 2>/dev/null || true

info "Billing-Status:"
gcloud billing projects describe "${PROJECT_ID}" \
  --format="value(billingEnabled)" 2>/dev/null || warn "Billing nicht abfragbar"

info "Aktivierte Kern-APIs:"
gcloud services list --enabled --project="${PROJECT_ID}" \
  --filter="config.name:(container.googleapis.com OR artifactregistry.googleapis.com OR compute.googleapis.com OR cloudresourcemanager.googleapis.com)" \
  --format="table(config.name)" 2>/dev/null || warn "APIs nicht abfragbar"

info "Artifact-Registry-Repos in ${REGION}:"
gcloud artifacts repositories list --location="${REGION}" --project="${PROJECT_ID}" \
  --format="table(name, format, createTime)" 2>/dev/null || warn "Registry nicht abfragbar"

ok "Prüfung abgeschlossen."
