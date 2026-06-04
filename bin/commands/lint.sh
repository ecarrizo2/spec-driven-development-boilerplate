#!/usr/bin/env bash
# bin/dev lint — Run linter (check only, no writes)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

log_step "Running linter..."

cmd="$(get_command "lint")"
if [[ -z "${cmd}" ]]; then
  log_error "No 'lint' command configured in sdd/config/commands.yaml"
  exit 1
fi

log_info "Running: ${cmd}"
eval "${cmd}"
exit_code=$?

if [[ ${exit_code} -eq 0 ]]; then
  log_success "Lint passed"
else
  log_error "Lint failed (exit code: ${exit_code})"
fi

exit ${exit_code}
