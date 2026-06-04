#!/usr/bin/env bash
# bin/dev wf:next — Show next approved plan(s) ready to execute
# ─────────────────────────────────────────────────────────────────────────────
# Scans plans for those with approval.status == "approved" that are not yet
# in-progress or done, and whose dependencies are satisfied.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

sdd_dir="$(get_sdd_dir)"
plans_dir="${sdd_dir}/agent-development/plans"

echo ""
echo -e "${_BOLD}┌─────────────────────────────────────────────────────────────┐${_RESET}"
echo -e "${_BOLD}│  Next Actionable Plans                                      │${_RESET}"
echo -e "${_BOLD}└─────────────────────────────────────────────────────────────┘${_RESET}"
echo ""

if [[ ! -d "${plans_dir}" ]]; then
  log_warn "Plans directory not found: ${plans_dir}"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Helper: check if a dependency task is done
# ─────────────────────────────────────────────────────────────────────────────
is_dependency_done() {
  local dep_name="$1"
  # Check in done/plans/
  local done_dir="${sdd_dir}/agent-development/done/plans"
  if [[ -d "${done_dir}/${dep_name}" ]]; then
    return 0
  fi
  # Check in active plans for status: done
  local dep_manifest="${plans_dir}/${dep_name}/manifest.yaml"
  if [[ -f "${dep_manifest}" ]]; then
    local dep_status
    dep_status=$(read_yaml_nested "${dep_manifest}" "plan_metadata" "status")
    if [[ "${dep_status}" == "done" ]]; then
      return 0
    fi
  fi
  return 1
}

# ─────────────────────────────────────────────────────────────────────────────
# Scan plans
# ─────────────────────────────────────────────────────────────────────────────
found_actionable=0

for plan_dir in "${plans_dir}"/*/; do
  [[ -d "${plan_dir}" ]] || continue
  [[ "$(basename "${plan_dir}")" == "_templates" ]] && continue

  manifest="${plan_dir}manifest.yaml"
  [[ -f "${manifest}" ]] || continue

  # Check approval status
  approval_status=$(grep -A5 "^  approval:" "${manifest}" 2>/dev/null | grep -m1 "status:" | sed 's/^.*status:[[:space:]]*//' | sed 's/[[:space:]]*#.*//')
  if [[ "${approval_status}" != "approved" ]]; then
    continue
  fi

  # Check plan status — skip if already in-progress or done
  plan_status=$(read_yaml_nested "${manifest}" "plan_metadata" "status")
  if [[ "${plan_status}" == "in-progress" || "${plan_status}" == "done" ]]; then
    continue
  fi

  # Check dependencies
  deps_met=true
  required_tasks=$(read_yaml_array "${manifest}" "required_tasks")
  if [[ -n "${required_tasks}" ]]; then
    while IFS= read -r dep; do
      [[ -z "${dep}" ]] && continue
      if ! is_dependency_done "${dep}"; then
        deps_met=false
        break
      fi
    done <<< "${required_tasks}"
  fi

  if [[ "${deps_met}" != "true" ]]; then
    continue
  fi

  # This plan is actionable
  ((found_actionable++))

  task_name=$(read_yaml_nested "${manifest}" "plan_metadata" "task_name")
  complexity=$(read_yaml_nested "${manifest}" "plan_metadata" "complexity")
  total_stages=$(read_yaml_nested "${manifest}" "plan_metadata" "total_stages")
  current_stage=$(read_yaml_nested "${manifest}" "plan_metadata" "current_stage")
  dir_name=$(basename "${plan_dir}")

  echo -e "  ${_GREEN}▶${_RESET} ${_CYAN}${dir_name}${_RESET} — ${task_name:-untitled}"
  stage_info=""
  if [[ -n "${total_stages}" && "${total_stages}" != "0" ]]; then
    stage_info=" | Stages: ${current_stage:-0}/${total_stages}"
  fi
  echo -e "    Status: ${plan_status:-unknown} | Complexity: ${complexity:-?}${stage_info}"
  echo ""
done

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
if [[ ${found_actionable} -eq 0 ]]; then
  log_info "No actionable plans found."
  echo ""
  echo -e "  ${_YELLOW}Possible reasons:${_RESET}"
  echo "    • No plans have been approved yet"
  echo "    • All approved plans are already in-progress or done"
  echo "    • Approved plans have unmet dependencies"
  echo ""
  echo -e "  Run ${_CYAN}bin/dev wf:status${_RESET} to see the full workflow state."
else
  log_success "Found ${found_actionable} actionable plan(s) ready to execute."
fi
echo ""
