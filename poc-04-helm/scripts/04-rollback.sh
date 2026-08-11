#!/usr/bin/env bash
# 04 – Rollback auf eine frühere Revision. Optionales Argument = Revision
# (Default: vorherige Revision).
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"
require_helm
require_vars RELEASE_NAME NAMESPACE

info "Aktuelle Historie:"
helm history "${RELEASE_NAME}" -n "${NAMESPACE}"

REV="${1:-0}"   # 0 = Helm wählt die unmittelbar vorherige Revision
info "Rollback '${RELEASE_NAME}' auf Revision ${REV} (0 = vorherige) …"
helm rollback "${RELEASE_NAME}" "${REV}" \
  --namespace "${NAMESPACE}" \
  --wait --timeout 5m

ok "Rollback fertig."
helm history "${RELEASE_NAME}" -n "${NAMESPACE}"
