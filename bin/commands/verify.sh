#!/usr/bin/env bash
# bin/dev verify [files...] — Fast verification loop
# ─────────────────────────────────────────────────────────────────────────────
# Detects what changed and runs only the relevant checks.
# If files are passed explicitly, uses those. Otherwise detects from git diff.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

log_step "Running verification..."

# Determine which files changed
changed_files=""
if [[ $# -gt 0 ]]; then
  changed_files="$*"
  log_info "Verifying specified files: ${changed_files}"
else
  base_branch="$(get_base_branch)"
  # Try to get diff against base branch, fall back to staged files
  if git rev-parse --verify "${base_branch}" &>/dev/null; then
    changed_files="$(git diff --name-only "${base_branch}"...HEAD 2>/dev/null || git diff --name-only --cached 2>/dev/null || "")"
  else
    changed_files="$(git diff --name-only --cached 2>/dev/null || "")"
  fi
  if [[ -z "${changed_files}" ]]; then
    # Fall back to unstaged changes
    changed_files="$(git diff --name-only 2>/dev/null || "")"
  fi
  if [[ -z "${changed_files}" ]]; then
    log_info "No changed files detected. Running full verification."
    # Run everything
    bin/dev lint && bin/dev typecheck && bin/dev test
    exit $?
  fi
  log_info "Changed files detected:"
  echo "${changed_files}" | head -20 | sed 's/^/  /'
  local file_count
  file_count=$(echo "${changed_files}" | wc -l | tr -d ' ')
  if [[ ${file_count} -gt 20 ]]; then
    log_info "  ... and $((file_count - 20)) more"
  fi
fi

# Determine what to run based on file extensions
run_lint=false
run_typecheck=false
run_test=false
run_prisma=false

while IFS= read -r file; do
  case "${file}" in
    *.md)
      # Markdown only — no checks needed
      ;;
    *.spec.ts|*.test.ts|*.spec.js|*.test.js)
      run_test=true
      ;;
    prisma/schema.prisma|*/schema.prisma)
      run_prisma=true
      run_typecheck=true
      ;;
    *.ts|*.tsx|*.js|*.jsx)
      run_lint=true
      run_typecheck=true
      run_test=true
      ;;
    *.json|*.yaml|*.yml)
      run_typecheck=true
      ;;
  esac
done <<< "${changed_files}"

# Execute in order
overall_exit=0

if [[ "${run_prisma}" == "true" ]]; then
  prisma_cmd="$(get_command "prisma_gen")"
  if [[ -n "${prisma_cmd}" ]]; then
    log_step "Regenerating Prisma client..."
    if ! eval "${prisma_cmd}"; then
      log_error "Prisma generation failed"
      overall_exit=1
    fi
  fi
fi

if [[ "${run_lint}" == "true" ]]; then
  log_step "Linting..."
  lint_cmd="$(get_command "lint")"
  if [[ -n "${lint_cmd}" ]]; then
    if ! eval "${lint_cmd}"; then
      log_error "Lint failed"
      overall_exit=1
    else
      log_success "Lint passed"
    fi
  fi
fi

if [[ "${run_typecheck}" == "true" ]]; then
  log_step "Type checking..."
  tc_cmd="$(get_command "typecheck")"
  if [[ -n "${tc_cmd}" ]]; then
    if ! eval "${tc_cmd}"; then
      log_error "Type check failed"
      overall_exit=1
    else
      log_success "Type check passed"
    fi
  fi
fi

if [[ "${run_test}" == "true" ]]; then
  log_step "Testing..."
  test_cmd="$(get_command "test")"
  if [[ -n "${test_cmd}" ]]; then
    # Scope tests to changed test files if possible
    test_files=$(echo "${changed_files}" | grep -E '\.(spec|test)\.(ts|js|tsx|jsx)$' || true)
    if [[ -n "${test_files}" ]]; then
      scoped_cmd="${test_cmd} ${test_files}"
      log_info "Running scoped: ${scoped_cmd}"
      if ! eval "${scoped_cmd}"; then
        log_error "Tests failed"
        overall_exit=1
      else
        log_success "Tests passed"
      fi
    else
      if ! eval "${test_cmd}"; then
        log_error "Tests failed"
        overall_exit=1
      else
        log_success "Tests passed"
      fi
    fi
  fi
fi

if [[ "${run_lint}" == "false" && "${run_typecheck}" == "false" && "${run_test}" == "false" && "${run_prisma}" == "false" ]]; then
  log_success "No verification needed for the changed files (docs/config only)"
fi

if [[ ${overall_exit} -eq 0 ]]; then
  echo ""
  log_success "All verification checks passed"
else
  echo ""
  log_error "Some verification checks failed"
fi

exit ${overall_exit}
