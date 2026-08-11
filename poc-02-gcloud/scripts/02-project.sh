#!/usr/bin/env bash
# 02 – Projekt erstellen/auswählen und Billing verknüpfen.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_gcloud
require_vars PROJECT_ID PROJECT_NAME

if gcloud projects describe "${PROJECT_ID}" >/dev/null 2>&1; then
  ok "Projekt ${PROJECT_ID} existiert bereits."
else
  info "Erstelle Projekt ${PROJECT_ID} …"
  gcloud projects create "${PROJECT_ID}" --name="${PROJECT_NAME}"
  ok "Projekt erstellt."
fi

info "Setze aktives Projekt auf ${PROJECT_ID}."
gcloud config set project "${PROJECT_ID}"

if [[ -n "${BILLING_ACCT:-}" ]]; then
  if gcloud billing projects describe "${PROJECT_ID}" \
       --format="value(billingEnabled)" 2>/dev/null | grep -qi true; then
    ok "Billing bereits verknüpft."
  else
    info "Verknüpfe Billing-Konto ${BILLING_ACCT} …"
    gcloud billing projects link "${PROJECT_ID}" --billing-account="${BILLING_ACCT}"
    ok "Billing verknüpft."
  fi
else
  warn "BILLING_ACCT leer – Billing-Verknüpfung übersprungen (GKE benötigt Billing!)."
  warn "Konten anzeigen:  gcloud billing accounts list"
fi
