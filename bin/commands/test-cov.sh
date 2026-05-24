#!/usr/bin/env bash
# bin/dev test:cov — Run tests with coverage report
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

log_step "Running tests with coverage..."

cmd="$(get_command "test_cov")"
if [[ -z "${cmd}" ]]; then
  log_error "No 'test_cov' command configured in sdd/config/commands.yaml"
  exit 1
fi

log_info "Running: ${cmd}"
eval "${cmd}"
exit_code=$?

if [[ ${exit_code} -eq 0 ]]; then
  log_success "Tests with coverage passed"
else
  log_error "Tests with coverage failed (exit code: ${exit_code})"
fi

exit ${exit_code}
