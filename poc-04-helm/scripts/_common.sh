#!/usr/bin/env bash
# Gemeinsame Helfer – von den nummerierten Skripten via `source` geladen.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POC_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

CONFIG_FILE="${POC_DIR}/config.env"
[[ -f "${POC_DIR}/config.local.env" ]] && CONFIG_FILE="${POC_DIR}/config.local.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "FEHLER: ${CONFIG_FILE} nicht gefunden." >&2
  exit 1
fi
# shellcheck disable=SC1090
source "${CONFIG_FILE}"

# --- kleine Ausgabe-Helfer -------------------------------------------------
info()  { printf '\033[1;34m▶ %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m✔ %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m⚠ %s\033[0m\n' "$*"; }
die()   { printf '\033[1;31m✘ %s\033[0m\n' "$*" >&2; exit 1; }

require_cmd()    { command -v "$1" >/dev/null 2>&1 || die "Kommando '$1' nicht gefunden."; }
require_gcloud() { require_cmd gcloud; }
require_kubectl(){ require_cmd kubectl; }
require_helm()   { require_cmd helm; }
require_docker() { require_cmd docker; }

# Pflichtvariablen prüfen (Namen als Argumente)
require_vars() {
  local v missing=0
  for v in "$@"; do
    if [[ -z "${!v:-}" ]]; then warn "Variable ${v} ist leer (config.env)."; missing=1; fi
  done
  [[ ${missing} -eq 0 ]] || die "Bitte config.env vervollständigen."
}

# Voll qualifizierter Image-Verweis in der Artifact Registry.
image_ref() {
  printf '%s-docker.pkg.dev/%s/%s/%s:%s' \
    "${REGION}" "${PROJECT_ID}" "${AR_REPO}" "${IMAGE_NAME}" "${IMAGE_TAG}"
}

# Absoluter Pfad zum Chart.
chart_path() { printf '%s/%s' "${POC_DIR}" "${CHART_DIR}"; }
