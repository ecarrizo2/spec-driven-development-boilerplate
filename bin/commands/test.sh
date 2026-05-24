#!/usr/bin/env bash
# bin/dev test [files...] — Run tests (optionally scoped)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

log_step "Running tests..."

cmd="$(get_command "test")"
if [[ -z "${cmd}" ]]; then
  log_error "No 'test' command configured in sdd/config/commands.yaml"
  exit 1
fi

# If files are passed, append them to the command
if [[ $# -gt 0 ]]; then
  cmd="${cmd} $*"
  log_info "Running (scoped): ${cmd}"
else
  log_info "Running: ${cmd}"
fi

eval "${cmd}"
exit_code=$?

if [[ ${exit_code} -eq 0 ]]; then
  log_success "Tests passed"
else
  log_error "Tests failed (exit code: ${exit_code})"
fi

exit ${exit_code}
