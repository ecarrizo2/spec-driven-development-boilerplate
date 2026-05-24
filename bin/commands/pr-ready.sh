#!/usr/bin/env bash
# bin/dev pr:ready — Promote draft PR to ready-for-review
# ─────────────────────────────────────────────────────────────────────────────
# Runs full verification before promoting. Fails if verification doesn't pass.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

require_git_repo
require_gh_auth

# Check PR exists
if ! gh pr view &>/dev/null 2>&1; then
  log_error "No PR found for current branch"
  log_info "Create one first: bin/dev pr:draft"
  exit 1
fi

# Run full verification first
log_step "Running full verification before marking as ready..."
echo ""

verify_script="${COMMANDS_DIR}/verify-full.sh"
if ! source "${verify_script}"; then
  echo ""
  log_error "Verification failed — PR will NOT be marked as ready"
  log_error "Fix the issues above and try again"
  exit 1
fi

echo ""
log_step "Marking PR as ready for review..."

if gh pr ready; then
  log_success "PR is now ready for review"
  pr_url=$(gh pr view --json url -q '.url')
  log_info "URL: ${pr_url}"
else
  log_error "Failed to mark PR as ready"
  exit 1
fi
