#!/usr/bin/env bash
# bin/dev status [epic-id] — Cross-repo epic status dashboard
set -euo pipefail

# Hub root (where config/, repos/, epics/ live)
SDD_ROOT="${SDD_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

EPIC_ID="${1:-}"

cd "${SDD_ROOT}"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  MULTIREPO HUB STATUS"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Show active epics
log_step "Active Epics:"
if [[ -d "epics/active" ]]; then
  epic_count=0
  for epic_dir in epics/active/*/; do
    [[ -d "${epic_dir}" ]] || continue
    epic_name=$(basename "${epic_dir}")
    [[ "${epic_name}" == ".gitkeep" ]] && continue
    echo "  📋 ${epic_name}"
    epic_count=$((epic_count + 1))

    # Show task summary if task-graph exists
    if [[ -f "${epic_dir}/task-graph.md" ]]; then
      total=$(grep -c "^  - id:" "${epic_dir}/task-graph.md" 2>/dev/null || echo "0")
      done_count=$(grep -c "status: done" "${epic_dir}/task-graph.md" 2>/dev/null || echo "0")
      in_progress=$(grep -c "status: in-progress" "${epic_dir}/task-graph.md" 2>/dev/null || echo "0")
      echo "     Tasks: ${done_count} done, ${in_progress} in-progress, ${total} total"
    fi
  done

  if [[ ${epic_count} -eq 0 ]]; then
    echo "  (none — create one with Prompt 5)"
  fi
else
  echo "  (epics/active/ not found)"
fi

echo ""

# Show repos summary
log_step "Repos:"
repo_count=0
for repo_dir in repos/*/; do
  [[ -d "${repo_dir}" ]] || continue
  repo_name=$(basename "${repo_dir}")
  [[ "${repo_name}" == ".gitkeep" ]] && continue

  if [[ -d "${repo_dir}/sdd" ]]; then
    sdd_status="own-sdd"
  elif [[ -d "fallback-sdd/${repo_name}" ]]; then
    sdd_status="fallback"
  else
    sdd_status="no-sdd"
  fi

  # Get current branch
  if [[ -d "${repo_dir}/.git" ]] || [[ -f "${repo_dir}/.git" ]]; then
    branch=$(cd "${repo_dir}" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
  else
    branch="not-cloned"
  fi

  printf "  %-20s [%s] branch: %s\n" "${repo_name}" "${sdd_status}" "${branch}"
  repo_count=$((repo_count + 1))
done

if [[ ${repo_count} -eq 0 ]]; then
  echo "  (none — add repos with 'bin/dev repo:add')"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
