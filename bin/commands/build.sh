#!/usr/bin/env bash
# bin/dev build — Compile/build the project
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

log_step "Building project..."

cmd="$(get_command "build")"
if [[ -z "${cmd}" ]]; then
  log_error "No 'build' command configured in sdd/config/commands.yaml"
  exit 1
fi

log_info "Running: ${cmd}"
eval "${cmd}"
exit_code=$?

if [[ ${exit_code} -eq 0 ]]; then
  log_success "Build passed"
else
  log_error "Build failed (exit code: ${exit_code})"
fi

exit ${exit_code}
