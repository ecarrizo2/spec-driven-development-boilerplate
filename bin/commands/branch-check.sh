#!/usr/bin/env bash
# bin/dev branch:check — Validate current branch name
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

require_git_repo

current="$(get_current_branch)"

if [[ -z "${current}" ]]; then
  log_error "Could not determine current branch (detached HEAD?)"
  exit 1
fi

# Check if on base branch
if is_on_base_branch; then
  log_error "You are on the base branch: ${current}"
  log_error "Create a feature branch before committing: bin/dev branch <type> <ticket> <desc>"
  exit 1
fi

# Validate format
valid_prefixes="feat/ fix/ chore/ hotfix/ refactor/ docs/ ci/ feature/ bugfix/"
has_valid_prefix=false
for prefix in ${valid_prefixes}; do
  if [[ "${current}" == ${prefix}* ]]; then
    has_valid_prefix=true
    break
  fi
done

if [[ "${has_valid_prefix}" == "false" ]]; then
  log_warn "Branch '${current}' does not follow naming conventions"
  log_warn "Expected format: <type>/<ticket-id>-<description> or <type>/<description>"
  log_warn "Valid prefixes: feat/ fix/ chore/ hotfix/ refactor/ docs/ ci/"
  exit 1
fi

# Check for ticket ID
ticket="$(get_ticket_from_branch "${current}")"
if [[ -n "${ticket}" ]]; then
  log_success "Branch: ${current}"
  log_info "Ticket: ${ticket} (will be included in commit messages)"
else
  log_success "Branch: ${current}"
  log_warn "No ticket ID detected — commits will not include a ticket reference"
fi
