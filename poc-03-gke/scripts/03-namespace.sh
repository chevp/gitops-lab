#!/usr/bin/env bash
# 03 – Namespace erstellen (idempotent).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars NAMESPACE

if kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
  ok "Namespace ${NAMESPACE} existiert bereits."
else
  info "Erstelle Namespace ${NAMESPACE} …"
  kubectl create namespace "${NAMESPACE}"
  ok "Namespace erstellt."
fi
