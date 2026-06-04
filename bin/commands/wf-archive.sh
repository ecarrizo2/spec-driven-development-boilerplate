#!/usr/bin/env bash
# bin/dev wf:archive <epic-name> [--dry-run] — Archive a completed epic
# ─────────────────────────────────────────────────────────────────────────────
# Moves an epic from epics/active/ to epics/done/, updates its status to
# "done", moves associated plans to agent-development/done/plans/, and commits.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

sdd_dir="$(get_sdd_dir)"

# ─────────────────────────────────────────────────────────────────────────────
# Parse arguments
# ─────────────────────────────────────────────────────────────────────────────
epic_name=""
dry_run=false

for arg in "$@"; do
  case "${arg}" in
    --dry-run) dry_run=true ;;
    -*) log_error "Unknown option: ${arg}"; exit 1 ;;
    *) epic_name="${arg}" ;;
  esac
done

if [[ -z "${epic_name}" ]]; then
  log_error "Usage: bin/dev wf:archive <epic-name> [--dry-run]"
  echo ""
  echo "  Archives a completed epic by:"
  echo "    1. Updating the epic's status to 'done'"
  echo "    2. Moving from epics/active/ to epics/done/"
  echo "    3. Moving associated plans to agent-development/done/plans/"
  echo "    4. Committing the changes"
  echo ""
  echo "  Options:"
  echo "    --dry-run  Show what would happen without making changes"
  echo ""

  # List available epics
  active_dir="${sdd_dir}/epics/active"
  if [[ -d "${active_dir}" ]]; then
    echo -e "  ${_BOLD}Active epics:${_RESET}"
    for edir in "${active_dir}"/*/; do
      [[ -d "${edir}" ]] || continue
      echo "    • $(basename "${edir}")"
    done
  fi
  exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Validate epic exists
# ─────────────────────────────────────────────────────────────────────────────
active_dir="${sdd_dir}/epics/active"
epic_dir="${active_dir}/${epic_name}"

if [[ ! -d "${epic_dir}" ]]; then
  log_error "Epic not found: ${epic_name}"
  echo ""
  echo "  Expected path: ${epic_dir}"
  echo ""
  if [[ -d "${active_dir}" ]]; then
    echo -e "  ${_BOLD}Available active epics:${_RESET}"
    for edir in "${active_dir}"/*/; do
      [[ -d "${edir}" ]] || continue
      echo "    • $(basename "${edir}")"
    done
  fi
  exit 1
fi

epic_file="${epic_dir}/epic.md"
if [[ ! -f "${epic_file}" ]]; then
  log_error "Epic file missing: ${epic_file}"
  exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# Identify associated plans
# ─────────────────────────────────────────────────────────────────────────────
plans_dir="${sdd_dir}/agent-development/plans"
associated_plans=()

if [[ -d "${plans_dir}" ]]; then
  for plan_dir in "${plans_dir}"/*/; do
    [[ -d "${plan_dir}" ]] || continue
    [[ "$(basename "${plan_dir}")" == "_templates" ]] && continue
    manifest="${plan_dir}manifest.yaml"
    [[ -f "${manifest}" ]] || continue

    # Check if this plan's task_name matches or references the epic
    # Convention: plans associated with an epic contain the epic name in their directory
    plan_name="$(basename "${plan_dir}")"
    if [[ "${plan_name}" == *"${epic_name}"* ]]; then
      associated_plans+=("${plan_name}")
    fi
  done
fi

# ─────────────────────────────────────────────────────────────────────────────
# Display plan
# ─────────────────────────────────────────────────────────────────────────────
echo ""
if [[ "${dry_run}" == "true" ]]; then
  echo -e "${_BOLD}┌─────────────────────────────────────────────────────────────┐${_RESET}"
  echo -e "${_BOLD}│  Archive Epic (DRY RUN)                                     │${_RESET}"
  echo -e "${_BOLD}└─────────────────────────────────────────────────────────────┘${_RESET}"
else
  echo -e "${_BOLD}┌─────────────────────────────────────────────────────────────┐${_RESET}"
  echo -e "${_BOLD}│  Archive Epic                                               │${_RESET}"
  echo -e "${_BOLD}└─────────────────────────────────────────────────────────────┘${_RESET}"
fi
echo ""

title=$(read_frontmatter_field "${epic_file}" "title")
current_status=$(read_frontmatter_field "${epic_file}" "status")

log_info "Epic: ${_CYAN}${epic_name}${_RESET} — ${title:-untitled}"
log_info "Current status: ${current_status:-unknown}"
echo ""

log_step "Actions to perform:"
echo "    1. Update epic status to 'done' in ${epic_file}"
echo "    2. Move ${epic_dir}/"
echo "       → ${sdd_dir}/epics/done/${epic_name}/"

if [[ ${#associated_plans[@]} -gt 0 ]]; then
  echo "    3. Move associated plans to done/plans/:"
  for plan in "${associated_plans[@]}"; do
    echo "       • ${plan}"
  done
else
  echo "    3. (no associated plans found)"
fi
echo "    4. Commit with: chore(sdd): archive epic ${epic_name}"
echo ""

if [[ "${dry_run}" == "true" ]]; then
  log_info "Dry run complete — no changes made."
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Execute archive
# ─────────────────────────────────────────────────────────────────────────────
require_git_repo

# 1. Update epic status to "done" in frontmatter
log_step "Updating epic status..."
if grep -q "^status:" "${epic_file}" 2>/dev/null; then
  # macOS-compatible sed (use '' for -i backup extension)
  sed -i '' "s/^status:.*$/status: done/" "${epic_file}"
elif head -20 "${epic_file}" | grep -q "^status:"; then
  sed -i '' "s/^status:.*$/status: done/" "${epic_file}"
fi
log_success "Status updated to 'done'"

# 2. Move epic directory
log_step "Moving epic to done/..."
done_dir="${sdd_dir}/epics/done"
mkdir -p "${done_dir}"
mv "${epic_dir}" "${done_dir}/${epic_name}"
log_success "Moved to epics/done/${epic_name}/"

# 3. Move associated plans
if [[ ${#associated_plans[@]} -gt 0 ]]; then
  log_step "Moving associated plans..."
  done_plans_dir="${sdd_dir}/agent-development/done/plans"
  mkdir -p "${done_plans_dir}"
  for plan in "${associated_plans[@]}"; do
    if [[ -d "${plans_dir}/${plan}" ]]; then
      mv "${plans_dir}/${plan}" "${done_plans_dir}/${plan}"
      log_success "  Moved plan: ${plan}"
    fi
  done
fi

# 4. Commit
log_step "Committing changes..."
cd "$(get_project_root)"
git add -A "${sdd_dir}/epics/" "${sdd_dir}/agent-development/"
commit_msg="chore(sdd): archive epic ${epic_name}"
co_author="$(get_co_author)"
if [[ -n "${co_author}" ]]; then
  git commit -m "${commit_msg}" -m "" -m "Co-authored-by: ${co_author}" --no-verify
else
  git commit -m "${commit_msg}" --no-verify
fi
log_success "Committed: ${commit_msg}"

echo ""
log_success "Epic '${epic_name}' archived successfully."
echo ""
