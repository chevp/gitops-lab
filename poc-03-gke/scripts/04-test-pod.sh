#!/usr/bin/env bash
# 04 – Test-Pod deployen und Bereitschaft abwarten.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars NAMESPACE

MANIFEST="${POC_DIR}/manifests/test-pod.yaml"

info "Deploye Test-Pod in Namespace ${NAMESPACE} …"
kubectl apply -n "${NAMESPACE}" -f "${MANIFEST}"

info "Warte auf Ready (max. 120s) …"
kubectl wait -n "${NAMESPACE}" --for=condition=Ready pod/hello-test --timeout=120s

ok "Test-Pod läuft:"
kubectl get pod -n "${NAMESPACE}" hello-test -o wide
