#!/usr/bin/env bash
# bin/dev review <pr-number> — Structured review packet for a PR
# ─────────────────────────────────────────────────────────────────────────────
# Produces: PR metadata + related plan context + blast radius + diff
# Usage: bin/dev review 109
#        bin/dev review 109 --no-diff
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

require_git_repo
require_gh_auth

# ─────────────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────────────
PR_NUMBER=""
SHOW_DIFF=true

for arg in "$@"; do
  case "${arg}" in
    --no-diff)
      SHOW_DIFF=false
      ;;
    --help|-h)
      PR_NUMBER=""
      break
      ;;
    *)
      if [[ -z "${PR_NUMBER}" && "${arg}" =~ ^[0-9]+$ ]]; then
        PR_NUMBER="${arg}"
      else
        log_error "Unknown argument: ${arg}"
        exit 1
      fi
      ;;
  esac
done

if [[ -z "${PR_NUMBER}" ]]; then
  log_error "Usage: bin/dev review <pr-number> [--no-diff]"
  echo ""
  echo "Produces a structured review packet:"
  echo "  • PR metadata (title, branch, changes)"
  echo "  • Related plan context (stages, blast radius)"
  echo "  • PR description"
  echo "  • Full diff (unless --no-diff)"
  echo ""
  echo "Examples:"
  echo "  bin/dev review 109"
  echo "  bin/dev review 109 --no-diff"
  exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Fetch PR metadata (single API call, extract fields with --jq)
# ─────────────────────────────────────────────────────────────────────────────
log_step "Fetching PR #${PR_NUMBER}..."

# Fetch all metadata in one call; output as tab-separated line for safe parsing
pr_data=$(gh pr view "${PR_NUMBER}" \
  --json title,state,headRefName,baseRefName,additions,deletions,changedFiles,url,isDraft \
  --jq '[.title, .state, .headRefName, .baseRefName, (.additions|tostring), (.deletions|tostring), (.changedFiles|tostring), .url, (.isDraft|tostring)] | @tsv' \
  2>/dev/null) || {
  log_error "Failed to fetch PR #${PR_NUMBER}"
  log_error "Make sure the PR exists and you have access to the repository."
  exit 1
}

# Parse tab-separated fields
IFS=$'\t' read -r pr_title pr_state pr_branch pr_base pr_additions pr_deletions pr_changed pr_url pr_draft <<< "${pr_data}"

# Fetch body separately (may contain tabs/newlines)
pr_body=$(gh pr view "${PR_NUMBER}" --json body --jq '.body' 2>/dev/null || echo "")

# ─────────────────────────────────────────────────────────────────────────────
# Display PR metadata
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${_BOLD}┌─────────────────────────────────────────────────────────────┐${_RESET}"
echo -e "${_BOLD}│  Review Packet: PR #${PR_NUMBER}                                       ${_RESET}"
echo -e "${_BOLD}└─────────────────────────────────────────────────────────────┘${_RESET}"
echo ""

# State badge
state_display="${pr_state}"
if [[ "${pr_draft}" == "true" ]]; then
  state_display="${pr_state} (DRAFT)"
fi

echo -e "${_BOLD}PR Metadata${_RESET}"
echo -e "  Title:    ${_CYAN}${pr_title}${_RESET}"
echo -e "  State:    ${state_display}"
echo -e "  Branch:   ${pr_branch} → ${pr_base}"
echo -e "  Changes:  ${_GREEN}+${pr_additions}${_RESET} / ${_RED}-${pr_deletions}${_RESET} across ${pr_changed} files"
echo -e "  URL:      ${pr_url}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Find related plan
# ─────────────────────────────────────────────────────────────────────────────
sdd_dir="$(get_sdd_dir)"
plans_dir="${sdd_dir}/agent-development/plans"
ticket=$(get_ticket_from_branch "${pr_branch}")

related_plan_dir=""
related_manifest=""

if [[ -d "${plans_dir}" ]]; then
  # Strategy 1: Match by branch name in delivery.branch
  for plan_dir in "${plans_dir}"/*/; do
    [[ -d "${plan_dir}" ]] || continue
    [[ "$(basename "${plan_dir}")" == "_templates" ]] && continue
    manifest="${plan_dir}manifest.yaml"
    [[ -f "${manifest}" ]] || continue

    plan_branch=$(read_yaml_nested "${manifest}" "delivery" "branch")
    if [[ -n "${plan_branch}" && "${plan_branch}" == "${pr_branch}" ]]; then
      related_plan_dir="${plan_dir}"
      related_manifest="${manifest}"
      break
    fi
  done

  # Strategy 2: Match by PR number in delivery.pr_number
  if [[ -z "${related_plan_dir}" ]]; then
    for plan_dir in "${plans_dir}"/*/; do
      [[ -d "${plan_dir}" ]] || continue
      [[ "$(basename "${plan_dir}")" == "_templates" ]] && continue
      manifest="${plan_dir}manifest.yaml"
      [[ -f "${manifest}" ]] || continue

      plan_pr_number=$(read_yaml_nested "${manifest}" "delivery" "pr_number")
      if [[ -n "${plan_pr_number}" && "${plan_pr_number}" == "${PR_NUMBER}" ]]; then
        related_plan_dir="${plan_dir}"
        related_manifest="${manifest}"
        break
      fi
    done
  fi

  # Strategy 3: Match by ticket ID in the plan directory name or task_id
  if [[ -z "${related_plan_dir}" && -n "${ticket}" ]]; then
    ticket_lower=$(echo "${ticket}" | tr '[:upper:]' '[:lower:]')
    for plan_dir in "${plans_dir}"/*/; do
      [[ -d "${plan_dir}" ]] || continue
      [[ "$(basename "${plan_dir}")" == "_templates" ]] && continue
      manifest="${plan_dir}manifest.yaml"
      [[ -f "${manifest}" ]] || continue

      dir_name=$(basename "${plan_dir}")
      dir_lower=$(echo "${dir_name}" | tr '[:upper:]' '[:lower:]')

      # Check if ticket appears in dir name
      if echo "${dir_lower}" | grep -qi "${ticket_lower}"; then
        related_plan_dir="${plan_dir}"
        related_manifest="${manifest}"
        break
      fi

      # Check branch field contains ticket
      plan_branch=$(read_yaml_nested "${manifest}" "delivery" "branch")
      if [[ -n "${plan_branch}" ]] && echo "${plan_branch}" | grep -qi "${ticket_lower}"; then
        related_plan_dir="${plan_dir}"
        related_manifest="${manifest}"
        break
      fi
    done
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Display plan context
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${_BOLD}Related Plan${_RESET}"

if [[ -n "${related_plan_dir}" && -f "${related_manifest}" ]]; then
  plan_name=$(basename "${related_plan_dir}")
  plan_task_name=$(read_yaml_nested "${related_manifest}" "plan_metadata" "task_name")
  plan_status=$(read_yaml_nested "${related_manifest}" "plan_metadata" "status")
  plan_current_stage=$(read_yaml_nested "${related_manifest}" "plan_metadata" "current_stage")
  plan_total_stages=$(read_yaml_nested "${related_manifest}" "plan_metadata" "total_stages")
  plan_complexity=$(read_yaml_nested "${related_manifest}" "plan_metadata" "complexity")

  echo -e "  Plan:       ${_CYAN}${plan_name}${_RESET}"
  echo -e "  Task:       ${plan_task_name:-untitled}"
  echo -e "  Status:     ${plan_status:-unknown}"
  echo -e "  Complexity: ${plan_complexity:-?}"

  if [[ -n "${plan_current_stage}" && -n "${plan_total_stages}" ]]; then
    echo -e "  Stages:     ${plan_current_stage} / ${plan_total_stages}"
  fi
  echo ""

  # ───────────────────────────────────────────────────────────────────────────
  # Blast radius (from stage files)
  # ───────────────────────────────────────────────────────────────────────────
  echo -e "${_BOLD}Blast Radius (from plan stages)${_RESET}"

  found_write_files=false
  for stage_file in "${related_plan_dir}"*.md; do
    [[ -f "${stage_file}" ]] || continue
    filename=$(basename "${stage_file}")

    # Look for "Allowed Write Access" section and extract paths
    if grep -q "Allowed Write Access" "${stage_file}" 2>/dev/null; then
      # Extract paths from the table after "Allowed Write Access"
      write_paths=$(sed -n '/### Allowed Write Access/,/###\|^---/p' "${stage_file}" 2>/dev/null \
        | grep '|' \
        | grep -v '^\s*|.*Path\|^\s*|.*---' \
        | sed 's/|//g' \
        | awk '{print $1}' \
        | grep -v '^$' \
        | sed 's/`//g')

      if [[ -n "${write_paths}" ]]; then
        found_write_files=true
        echo -e "  ${_YELLOW}${filename}:${_RESET}"
        while IFS= read -r path; do
          [[ -n "${path}" ]] && echo "    • ${path}"
        done <<< "${write_paths}"
      fi
    fi
  done

  if [[ "${found_write_files}" == "false" ]]; then
    echo "  (no blast radius information found in stage files)"
  fi
  echo ""

  # Show affected modules from manifest
  affected_modules=$(read_yaml_array "${related_manifest}" "affected_modules" 2>/dev/null || echo "")
  if [[ -n "${affected_modules}" ]]; then
    echo -e "${_BOLD}Affected Modules${_RESET}"
    while IFS= read -r module; do
      [[ -n "${module}" ]] && echo "  • ${module}"
    done <<< "${affected_modules}"
    echo ""
  fi
else
  if [[ -n "${ticket}" ]]; then
    echo -e "  ${_YELLOW}No related plan found for ticket ${ticket}${_RESET}"
  else
    echo -e "  ${_YELLOW}No related plan found (could not extract ticket from branch: ${pr_branch})${_RESET}"
  fi
  echo ""
fi

# ─────────────────────────────────────────────────────────────────────────────
# PR Description
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${_BOLD}PR Description${_RESET}"
echo -e "${_BOLD}─────────────────────────────────────────────────────────────────${_RESET}"

if [[ -n "${pr_body}" && "${pr_body}" != "null" ]]; then
  echo "${pr_body}"
else
  echo "  (no description)"
fi

echo -e "${_BOLD}─────────────────────────────────────────────────────────────────${_RESET}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Diff
# ─────────────────────────────────────────────────────────────────────────────
if [[ "${SHOW_DIFF}" == "true" ]]; then
  echo -e "${_BOLD}Diff${_RESET}"
  echo -e "${_BOLD}─────────────────────────────────────────────────────────────────${_RESET}"
  gh pr diff "${PR_NUMBER}" || {
    log_warn "Failed to fetch diff for PR #${PR_NUMBER}"
  }
  echo -e "${_BOLD}─────────────────────────────────────────────────────────────────${_RESET}"
else
  log_info "Diff skipped (--no-diff flag)"
fi

echo ""
log_success "Review packet complete for PR #${PR_NUMBER}"
