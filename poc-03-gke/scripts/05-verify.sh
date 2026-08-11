#!/usr/bin/env bash
# 05 – Cluster prüfen (Definition of Done für PoC 03).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_kubectl
require_vars NAMESPACE

info "kubectl-Kontext:"
kubectl config current-context || warn "kein Kontext gesetzt"

info "Cluster-Info:"
kubectl cluster-info | head -3

info "Nodes:"
kubectl get nodes -o wide

info "Namespaces:"
kubectl get namespace "${NAMESPACE}"

info "Pods in ${NAMESPACE}:"
kubectl get pods -n "${NAMESPACE}" -o wide

ok "Prüfung abgeschlossen."
