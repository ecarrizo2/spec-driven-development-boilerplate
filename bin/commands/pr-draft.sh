#!/usr/bin/env bash
# bin/dev pr:draft [title] — Open a draft PR for current branch
# ─────────────────────────────────────────────────────────────────────────────
# Uses gh CLI to create a draft PR. Generates title from branch if not provided.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

require_git_repo
require_gh_auth

current_branch="$(get_current_branch)"
base_branch="$(get_base_branch)"
ticket="$(get_ticket_from_branch "${current_branch}")"

# Check if PR already exists
existing_pr="$(gh pr view --json number,url 2>/dev/null || echo "")"
if [[ -n "${existing_pr}" ]]; then
  pr_url=$(echo "${existing_pr}" | grep -o '"url":"[^"]*"' | sed 's/"url":"//;s/"//')
  log_warn "PR already exists for this branch"
  log_info "URL: ${pr_url}"
  exit 0
fi

# Determine title
if [[ $# -gt 0 ]]; then
  pr_title="$*"
else
  # Generate title from branch name
  # Remove type prefix and ticket, capitalize first letter
  raw_title=$(echo "${current_branch}" | sed 's|^[^/]*/||' | sed "s|${ticket}-||" | tr '-' ' ')
  # Add ticket prefix if available
  if [[ -n "${ticket}" ]]; then
    pr_title="${ticket} ${raw_title}"
  else
    pr_title="${raw_title}"
  fi
fi

# Build PR body
pr_body="## Summary

<!-- Brief description of what this PR does -->

## Ticket

"
if [[ -n "${ticket}" ]]; then
  pr_body+="[${ticket}](https://theknotww.atlassian.net/browse/${ticket})"
else
  pr_body+="_No ticket linked_"
fi

pr_body+="

## Review Guide

| Commit | Stage | Focus |
|--------|-------|-------|
| _to be filled as commits land_ | | |

## Verification

- [ ] \`bin/dev verify:full\` passes
- [ ] Manual testing completed (if applicable)
"

# Create the draft PR
log_step "Creating draft PR..."
log_info "Title: ${pr_title}"
log_info "Base: ${base_branch}"

pr_url=$(gh pr create \
  --draft \
  --base "${base_branch}" \
  --title "${pr_title}" \
  --body "${pr_body}" \
  2>&1)

if [[ $? -eq 0 ]]; then
  log_success "Draft PR created: ${pr_url}"
else
  log_error "Failed to create PR"
  echo "${pr_url}"
  exit 1
fi
