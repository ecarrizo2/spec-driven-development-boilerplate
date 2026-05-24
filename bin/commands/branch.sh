#!/usr/bin/env bash
# bin/dev branch <type> <ticket-id> <description> — Create a branch
# ─────────────────────────────────────────────────────────────────────────────
# Creates a branch following the conventions in sdd/config/teams.yaml.
# Usage: bin/dev branch feat GPMP-123 add-vendor-filters
#        bin/dev branch fix GPMP-456 correct-pagination
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

require_git_repo

# Parse arguments
if [[ $# -lt 2 ]]; then
  log_error "Usage: bin/dev branch <type> <ticket-id> <description>"
  log_error "       bin/dev branch <type> <description>  (no ticket)"
  echo ""
  echo "Examples:"
  echo "  bin/dev branch feat GPMP-123 add-vendor-filters"
  echo "  bin/dev branch fix correct-pagination-offset"
  exit 1
fi

branch_type="$1"
shift

# Validate branch type
valid_types="feat fix chore hotfix refactor docs ci feature bugfix"
if ! echo "${valid_types}" | grep -qw "${branch_type}"; then
  log_error "Invalid branch type: ${branch_type}"
  log_error "Valid types: ${valid_types}"
  exit 1
fi

# Determine if second arg is a ticket ID or description
ticket_pattern="$(get_branching_config "ticket_id_pattern")"
[[ -z "${ticket_pattern}" ]] && ticket_pattern='[A-Z][A-Z0-9]+-[0-9]+'

ticket_id=""
description=""

if echo "$1" | grep -qE "^${ticket_pattern}$"; then
  ticket_id="$1"
  shift
  if [[ $# -lt 1 ]]; then
    log_error "Missing description after ticket ID"
    exit 1
  fi
  description="$*"
else
  description="$*"
fi

# Sanitize description: lowercase, replace spaces with hyphens, remove special chars
description=$(echo "${description}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

# Build branch name
if [[ -n "${ticket_id}" ]]; then
  branch_name="${branch_type}/${ticket_id}-${description}"
else
  branch_name="${branch_type}/${description}"
  log_warn "No ticket ID provided. Branch: ${branch_name}"
  log_warn "Commit messages will not include a ticket reference."
fi

# Check if branch already exists
if git rev-parse --verify "${branch_name}" &>/dev/null 2>&1; then
  log_error "Branch already exists: ${branch_name}"
  log_info "To switch to it: git checkout ${branch_name}"
  exit 1
fi

# Create and checkout
log_step "Creating branch: ${branch_name}"
base_branch="$(get_base_branch)"

git checkout -b "${branch_name}" "${base_branch}" 2>/dev/null || git checkout -b "${branch_name}"
log_success "Created and switched to: ${branch_name}"

# Offer to push
echo ""
log_info "Push with: git push -u origin ${branch_name}"
