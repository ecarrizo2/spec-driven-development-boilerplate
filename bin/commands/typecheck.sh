#!/usr/bin/env bash
# bin/dev typecheck — Run type checker (no emit)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

log_step "Running type checker..."

cmd="$(get_command "typecheck")"
if [[ -z "${cmd}" ]]; then
  log_error "No 'typecheck' command configured in sdd/config/commands.yaml"
  exit 1
fi

log_info "Running: ${cmd}"
eval "${cmd}"
exit_code=$?

if [[ ${exit_code} -eq 0 ]]; then
  log_success "Type check passed"
else
  log_error "Type check failed (exit code: ${exit_code})"
fi

exit ${exit_code}
