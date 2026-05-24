#!/usr/bin/env bash
# bin/dev wf:status — Show status of epics, tasks, and plans
# ─────────────────────────────────────────────────────────────────────────────
# Scans sdd/ directories and reads YAML frontmatter to show a summary.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

sdd_dir="$(get_sdd_dir)"

echo ""
echo -e "${_BOLD}┌─────────────────────────────────────────────────────────────┐${_RESET}"
echo -e "${_BOLD}│  SDD Workflow Status                                        │${_RESET}"
echo -e "${_BOLD}└─────────────────────────────────────────────────────────────┘${_RESET}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Active Epics
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${_BOLD}Active Epics:${_RESET}"
epics_dir="${sdd_dir}/epics/active"
if [[ -d "${epics_dir}" ]]; then
  found_epics=false
  for epic_dir in "${epics_dir}"/*/; do
    [[ -d "${epic_dir}" ]] || continue
    epic_file="${epic_dir}epic.md"
    [[ -f "${epic_file}" ]] || continue
    found_epics=true

    # Extract frontmatter fields
    frontmatter="$(extract_frontmatter "${epic_file}")"
    title=$(echo "${frontmatter}" | grep -m1 "^title:" | sed 's/^title:[[:space:]]*//' | sed 's/^["'\'']//' | sed 's/["'\'']*$//')
    status=$(echo "${frontmatter}" | grep -m1 "^status:" | sed 's/^status:[[:space:]]*//')
    complexity=$(echo "${frontmatter}" | grep -m1 "^complexity:" | sed 's/^complexity:[[:space:]]*//')

    # Count tasks if task-graph exists
    task_info=""
    task_graph="${epic_dir}task-graph.md"
    if [[ -f "${task_graph}" ]]; then
      tg_front="$(extract_frontmatter "${task_graph}")"
      total=$(echo "${tg_front}" | grep -m1 "^total_tasks:" | sed 's/^total_tasks:[[:space:]]*//')
      done_count=$(echo "${tg_front}" | grep -c "status: done" || echo "0")
      if [[ -n "${total}" ]]; then
        task_info=" (${done_count}/${total} tasks done)"
      fi
    fi

    dir_name=$(basename "${epic_dir}")
    echo -e "  ${_CYAN}${dir_name}${_RESET} — ${title:-untitled}"
    echo -e "    Status: ${status:-unknown} | Complexity: ${complexity:-?}${task_info}"
  done
  if [[ "${found_epics}" == "false" ]]; then
    echo "  (none)"
  fi
else
  echo "  (no epics directory)"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Pending Requests
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${_BOLD}Pending Requests:${_RESET}"
pending_dir="${sdd_dir}/agent-development/pending"
if [[ -d "${pending_dir}" ]]; then
  found_requests=false
  for req_file in "${pending_dir}"/*.md; do
    [[ -f "${req_file}" ]] || continue
    [[ "$(basename "${req_file}")" == "_TEMPLATE-request.md" ]] && continue
    found_requests=true

    frontmatter="$(extract_frontmatter "${req_file}")"
    title=$(echo "${frontmatter}" | grep -m1 "^title:" | sed 's/^title:[[:space:]]*//' | sed 's/^["'\'']//' | sed 's/["'\'']*$//')
    status=$(echo "${frontmatter}" | grep -m1 "^status:" | sed 's/^status:[[:space:]]*//')
    complexity=$(echo "${frontmatter}" | grep -m1 "^complexity:" | sed 's/^complexity:[[:space:]]*//')

    filename=$(basename "${req_file}")
    echo -e "  ${_CYAN}${filename}${_RESET} — ${title:-untitled}"
    echo -e "    Status: ${status:-unknown} | Complexity: ${complexity:-?}"
  done
  if [[ "${found_requests}" == "false" ]]; then
    echo "  (none)"
  fi
else
  echo "  (no pending directory)"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Plans
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${_BOLD}Plans:${_RESET}"
plans_dir="${sdd_dir}/agent-development/plans"
if [[ -d "${plans_dir}" ]]; then
  found_plans=false
  for plan_dir in "${plans_dir}"/*/; do
    [[ -d "${plan_dir}" ]] || continue
    [[ "$(basename "${plan_dir}")" == "_templates" ]] && continue
    manifest="${plan_dir}manifest.yaml"
    [[ -f "${manifest}" ]] || continue
    found_plans=true

    task_name=$(read_yaml_nested "${manifest}" "plan_metadata" "task_name")
    status=$(read_yaml_nested "${manifest}" "plan_metadata" "status")
    complexity=$(read_yaml_nested "${manifest}" "plan_metadata" "complexity")
    approval=$(read_yaml_nested "${manifest}" "plan_metadata" "approval")
    # Try to get approval status directly
    approval_status=$(grep -A5 "^  approval:" "${manifest}" 2>/dev/null | grep -m1 "status:" | sed 's/^.*status:[[:space:]]*//')
    current_stage=$(read_yaml_nested "${manifest}" "plan_metadata" "current_stage")
    total_stages=$(read_yaml_nested "${manifest}" "plan_metadata" "total_stages")

    dir_name=$(basename "${plan_dir}")
    echo -e "  ${_CYAN}${dir_name}${_RESET} — ${task_name:-untitled}"
    stage_info=""
    if [[ -n "${current_stage}" && -n "${total_stages}" ]]; then
      stage_info=" | Stage: ${current_stage}/${total_stages}"
    fi
    echo -e "    Status: ${status:-unknown} | Approval: ${approval_status:-pending} | Complexity: ${complexity:-?}${stage_info}"
  done
  if [[ "${found_plans}" == "false" ]]; then
    echo "  (none)"
  fi
else
  echo "  (no plans directory)"
fi
echo ""
