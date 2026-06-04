#!/usr/bin/env bash
# bin/dev lint:fix — Run linter with auto-fix
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

log_step "Running linter with auto-fix..."

cmd="$(get_command "lint_fix")"
if [[ -z "${cmd}" ]]; then
  log_error "No 'lint_fix' command configured in sdd/config/commands.yaml"
  exit 1
fi

log_info "Running: ${cmd}"
eval "${cmd}"
exit_code=$?

if [[ ${exit_code} -eq 0 ]]; then
  log_success "Lint fix complete"
else
  log_error "Lint fix failed (exit code: ${exit_code})"
fi

exit ${exit_code}
