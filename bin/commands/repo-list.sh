#!/usr/bin/env bash
# bin/dev repo:list — Show all registered repos with their status
set -euo pipefail

# Hub root (where config/, repos/, epics/ live)
SDD_ROOT="${SDD_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

log_step "Registered repositories:"
echo ""

# Parse repos.yaml and show status
if [[ ! -f "${SDD_ROOT}/config/repos.yaml" ]]; then
  log_error "config/repos.yaml not found. Is this a multirepo hub?"
  exit 1
fi

# Simple YAML parsing for repo names and basic info
printf "%-20s %-12s %-10s %s\n" "REPO" "HAS SDD" "SUBMODULE" "DESCRIPTION"
printf "%-20s %-12s %-10s %s\n" "────" "───────" "─────────" "───────────"

while IFS= read -r repo_key; do
  # Check if submodule exists
  submodule_path="${SDD_ROOT}/repos/${repo_key}"
  if [[ -d "${submodule_path}/.git" ]] || [[ -f "${submodule_path}/.git" ]]; then
    submodule_status="✓ cloned"
  else
    submodule_status="✗ missing"
  fi

  # Check if repo has own SDD
  if [[ -d "${submodule_path}/sdd" ]]; then
    has_sdd="✓ own"
  elif [[ -d "${SDD_ROOT}/fallback-sdd/${repo_key}" ]]; then
    has_sdd="⟳ fallback"
  else
    has_sdd="✗ none"
  fi

  printf "%-20s %-12s %-10s\n" "${repo_key}" "${has_sdd}" "${submodule_status}"
done < <(awk '/^repositories:/{found=1; next} /^[a-z]/{found=0} found && /^  [a-zA-Z]/' "${SDD_ROOT}/config/repos.yaml" | grep -v "^  #" | sed 's/://g' | awk '{print $1}' | head -20)

echo ""
log_success "Use 'bin/dev repo:enter <name>' to work with a specific repo"
