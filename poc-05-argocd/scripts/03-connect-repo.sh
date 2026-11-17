#!/usr/bin/env bash
# 03 – GitHub-Repository in Argo CD registrieren.
# Für ein ÖFFENTLICHES Repo optional (Argo CD kann es auch ohne Anbindung lesen),
# für ein PRIVATES Repo mit --username/--token nötig.
#
# Voraussetzung: 'argocd login' ist erfolgt (siehe 02-access.sh).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_argocd
require_vars GIT_REPO_URL

require_cmd argocd || true

info "Registrierte Repositories:"
argocd repo list || die "Nicht eingeloggt? Zuerst: argocd login localhost:8080 --insecure"

# Für privates Repo Token setzen:
#   export GIT_USERNAME=chevp GIT_TOKEN=ghp_...
if [[ -n "${GIT_TOKEN:-}" ]]; then
  info "Füge PRIVATES Repo '${GIT_REPO_URL}' mit Token hinzu …"
  argocd repo add "${GIT_REPO_URL}" \
    --username "${GIT_USERNAME:-git}" \
    --password "${GIT_TOKEN}"
else
  info "Füge ÖFFENTLICHES Repo '${GIT_REPO_URL}' hinzu …"
  argocd repo add "${GIT_REPO_URL}"
fi

ok "Repository verbunden."
