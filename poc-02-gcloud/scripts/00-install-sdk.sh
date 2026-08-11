#!/usr/bin/env bash
# 00 – Google Cloud SDK installieren/prüfen (macOS / Homebrew).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"

if command -v gcloud >/dev/null 2>&1; then
  ok "gcloud bereits installiert: $(gcloud version --format='value(\"Google Cloud SDK\")' 2>/dev/null | head -1)"
  exit 0
fi

info "gcloud nicht gefunden – Installation via Homebrew."
if command -v brew >/dev/null 2>&1; then
  brew install --cask google-cloud-sdk
  ok "Installiert. Ggf. neue Shell öffnen, damit 'gcloud' im PATH ist."
else
  die "Homebrew nicht gefunden. Manuell installieren: https://cloud.google.com/sdk/docs/install"
fi
