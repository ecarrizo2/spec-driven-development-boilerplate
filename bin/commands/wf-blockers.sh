#!/usr/bin/env bash
# bin/dev wf:blockers — List open questions and blockers across active plans
# ─────────────────────────────────────────────────────────────────────────────
# Scans plans for:
#   1. "Open Questions" sections in specification.md with unresolved items
#   2. Amendments in manifest.yaml with status: pending
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

sdd_dir="$(get_sdd_dir)"
plans_dir="${sdd_dir}/agent-development/plans"

echo ""
echo -e "${_BOLD}┌─────────────────────────────────────────────────────────────┐${_RESET}"
echo -e "${_BOLD}│  Open Blockers & Questions                                  │${_RESET}"
echo -e "${_BOLD}└─────────────────────────────────────────────────────────────┘${_RESET}"
echo ""

if [[ ! -d "${plans_dir}" ]]; then
  log_warn "Plans directory not found: ${plans_dir}"
  exit 0
fi

total_blockers=0
total_questions=0
plans_with_issues=0

for plan_dir in "${plans_dir}"/*/; do
  [[ -d "${plan_dir}" ]] || continue
  [[ "$(basename "${plan_dir}")" == "_templates" ]] && continue

  dir_name=$(basename "${plan_dir}")
  manifest="${plan_dir}manifest.yaml"
  spec_file="${plan_dir}specification.md"

  plan_questions=()
  plan_amendments=()

  # ─────────────────────────────────────────────────────────────────────────
  # Check specification.md for open questions
  # ─────────────────────────────────────────────────────────────────────────
  if [[ -f "${spec_file}" ]]; then
    in_open_questions=false
    while IFS= read -r line; do
      # Detect "Open Questions" section (any heading level)
      if echo "${line}" | grep -qi "^#.*open.question"; then
        in_open_questions=true
        continue
      fi
      # Exit section on next heading
      if [[ "${in_open_questions}" == "true" ]] && echo "${line}" | grep -q "^#"; then
        in_open_questions=false
        continue
      fi
      # Collect unresolved items (checkbox not checked, not marked RESOLVED)
      if [[ "${in_open_questions}" == "true" ]]; then
        # Match unchecked checkboxes: - [ ] or * [ ]
        if echo "${line}" | grep -qE "^[[:space:]]*[-*][[:space:]]+\[ \]"; then
          item=$(echo "${line}" | sed 's/^[[:space:]]*[-*][[:space:]]*\[ \][[:space:]]*//')
          plan_questions+=("${item}")
        # Match plain list items that are NOT resolved
        elif echo "${line}" | grep -qE "^[[:space:]]*[-*][[:space:]]+" && ! echo "${line}" | grep -qi "RESOLVED" && ! echo "${line}" | grep -qE "\[x\]"; then
          # Only include if it's not a checked item
          if ! echo "${line}" | grep -qE "^[[:space:]]*[-*][[:space:]]+\[x\]"; then
            item=$(echo "${line}" | sed 's/^[[:space:]]*[-*][[:space:]]*//')
            # Skip empty items
            [[ -n "${item}" ]] && plan_questions+=("${item}")
          fi
        fi
      fi
    done < "${spec_file}"
  fi

  # ─────────────────────────────────────────────────────────────────────────
  # Check manifest.yaml for pending amendments
  # ─────────────────────────────────────────────────────────────────────────
  if [[ -f "${manifest}" ]]; then
    in_amendments=false
    current_amendment=""
    current_status=""

    while IFS= read -r line; do
      # Detect amendments section
      if echo "${line}" | grep -q "^amendments:"; then
        in_amendments=true
        continue
      fi
      # Exit on next top-level key
      if [[ "${in_amendments}" == "true" ]] && echo "${line}" | grep -qE "^[a-z_]+:"; then
        # Flush last amendment
        if [[ "${current_status}" == "pending" && -n "${current_amendment}" ]]; then
          plan_amendments+=("${current_amendment}")
        fi
        in_amendments=false
        continue
      fi
      if [[ "${in_amendments}" == "true" ]]; then
        # New amendment item
        if echo "${line}" | grep -qE "^[[:space:]]*-[[:space:]]"; then
          # Flush previous
          if [[ "${current_status}" == "pending" && -n "${current_amendment}" ]]; then
            plan_amendments+=("${current_amendment}")
          fi
          current_amendment=""
          current_status=""
        fi
        # Capture description/title
        if echo "${line}" | grep -q "description:"; then
          current_amendment=$(echo "${line}" | sed 's/^.*description:[[:space:]]*//' | sed 's/^["'\'']//' | sed 's/["'\'']*$//')
        elif echo "${line}" | grep -q "title:"; then
          current_amendment=$(echo "${line}" | sed 's/^.*title:[[:space:]]*//' | sed 's/^["'\'']//' | sed 's/["'\'']*$//')
        fi
        # Capture status
        if echo "${line}" | grep -q "status:"; then
          current_status=$(echo "${line}" | sed 's/^.*status:[[:space:]]*//' | sed 's/[[:space:]]*#.*//')
        fi
      fi
    done < "${manifest}"

    # Flush final amendment if we ended inside the section
    if [[ "${in_amendments}" == "true" && "${current_status}" == "pending" && -n "${current_amendment}" ]]; then
      plan_amendments+=("${current_amendment}")
    fi
  fi

  # ─────────────────────────────────────────────────────────────────────────
  # Print results for this plan
  # ─────────────────────────────────────────────────────────────────────────
  question_count=${#plan_questions[@]}
  amendment_count=${#plan_amendments[@]}

  if [[ ${question_count} -eq 0 && ${amendment_count} -eq 0 ]]; then
    continue
  fi

  ((plans_with_issues++))

  # Get plan name for display
  task_name=""
  if [[ -f "${manifest}" ]]; then
    task_name=$(read_yaml_nested "${manifest}" "plan_metadata" "task_name")
  fi

  echo -e "  ${_CYAN}${dir_name}${_RESET} — ${task_name:-untitled}"

  if [[ ${question_count} -gt 0 ]]; then
    echo -e "    ${_YELLOW}Open Questions (${question_count}):${_RESET}"
    for q in "${plan_questions[@]}"; do
      echo -e "      ${_YELLOW}?${_RESET} ${q}"
      ((total_questions++))
    done
  fi

  if [[ ${amendment_count} -gt 0 ]]; then
    echo -e "    ${_RED}Pending Amendments (${amendment_count}):${_RESET}"
    for a in "${plan_amendments[@]}"; do
      echo -e "      ${_RED}!${_RESET} ${a}"
      ((total_blockers++))
    done
  fi

  echo ""
done

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
if [[ ${plans_with_issues} -eq 0 ]]; then
  log_success "No open blockers or questions found across active plans."
  echo ""
else
  echo -e "${_BOLD}Summary:${_RESET}"
  echo -e "  Plans with issues: ${plans_with_issues}"
  if [[ ${total_questions} -gt 0 ]]; then
    echo -e "  Open questions:    ${_YELLOW}${total_questions}${_RESET}"
  fi
  if [[ ${total_blockers} -gt 0 ]]; then
    echo -e "  Pending amendments: ${_RED}${total_blockers}${_RESET}"
  fi
  echo ""
fi
