#!/usr/bin/env bash
# bin/dev verify:full — Full verification suite
# ─────────────────────────────────────────────────────────────────────────────
# Runs: build + lint + typecheck + test (all files, no scoping)
# Use after completing all stages or before marking a PR as ready.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

log_step "Running full verification suite..."
echo ""

overall_exit=0

# 1. Build
log_step "[1/4] Build"
build_cmd="$(get_command "build")"
if [[ -n "${build_cmd}" ]]; then
  if eval "${build_cmd}"; then
    log_success "Build passed"
  else
    log_error "Build failed"
    overall_exit=1
  fi
fi
echo ""

# 2. Lint
log_step "[2/4] Lint"
lint_cmd="$(get_command "lint")"
if [[ -n "${lint_cmd}" ]]; then
  if eval "${lint_cmd}"; then
    log_success "Lint passed"
  else
    log_error "Lint failed"
    overall_exit=1
  fi
fi
echo ""

# 3. Type check
log_step "[3/4] Type check"
tc_cmd="$(get_command "typecheck")"
if [[ -n "${tc_cmd}" ]]; then
  if eval "${tc_cmd}"; then
    log_success "Type check passed"
  else
    log_error "Type check failed"
    overall_exit=1
  fi
fi
echo ""

# 4. Tests
log_step "[4/4] Tests"
test_cmd="$(get_command "test")"
if [[ -n "${test_cmd}" ]]; then
  if eval "${test_cmd}"; then
    log_success "Tests passed"
  else
    log_error "Tests failed"
    overall_exit=1
  fi
fi
echo ""

# Summary
echo "─────────────────────────────────────────"
if [[ ${overall_exit} -eq 0 ]]; then
  log_success "Full verification suite PASSED"
else
  log_error "Full verification suite FAILED"
fi

exit ${overall_exit}
