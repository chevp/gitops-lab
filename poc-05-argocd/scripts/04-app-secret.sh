#!/usr/bin/env bash
# 04 – OpenAI-Secret im Ziel-Namespace anlegen (liegt bewusst NICHT im Git).
# Das Chart referenziert es über openai.existingSecret (von der Application gesetzt).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars NAMESPACE OPENAI_SECRET_NAME

[[ -n "${OPENAI_API_KEY:-}" ]] \
  || die "OPENAI_API_KEY ist leer. Setze: export OPENAI_API_KEY=sk-..."

info "Stelle Namespace '${NAMESPACE}' sicher …"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

info "Lege/aktualisiere Secret '${OPENAI_SECRET_NAME}' in '${NAMESPACE}' …"
kubectl create secret generic "${OPENAI_SECRET_NAME}" \
  --namespace "${NAMESPACE}" \
  --from-literal=OPENAI_API_KEY="${OPENAI_API_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -

ok "Secret bereit. Schlüssel: OPENAI_API_KEY"
