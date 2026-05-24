#!/usr/bin/env bash
# bin/dev pr:status — Show PR status for current branch
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

require_git_repo
require_gh_auth

if ! gh pr view &>/dev/null 2>&1; then
  log_info "No PR found for branch: $(get_current_branch)"
  exit 0
fi

# Show PR info
gh pr view --json title,state,number,url,isDraft,reviewDecision,statusCheckRollup \
  --template '{{.title}} (#{{.number}})
State: {{.state}}{{if .isDraft}} (DRAFT){{end}}
Review: {{if .reviewDecision}}{{.reviewDecision}}{{else}}pending{{end}}
URL: {{.url}}
{{if .statusCheckRollup}}Checks:{{range .statusCheckRollup}} {{.name}}: {{.conclusion}}{{end}}{{end}}
'
