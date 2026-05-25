#!/usr/bin/env bash
# bin/dev repo:enter <name> — Print context for working in a specific repo
set -euo pipefail

# Hub root (where config/, repos/, epics/ live)
SDD_ROOT="${SDD_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

REPO_NAME="${1:-}"

if [[ -z "${REPO_NAME}" ]]; then
  log_error "Usage: bin/dev repo:enter <name>"
  log_info "Run 'bin/dev repo:list' to see available repos"
  exit 1
fi

submodule_path="${SDD_ROOT}/repos/${REPO_NAME}"

# Check submodule exists
if [[ ! -d "${submodule_path}" ]]; then
  log_error "Repo '${REPO_NAME}' not found at repos/${REPO_NAME}"
  exit 1
fi

echo ""
log_step "Context for: ${REPO_NAME}"
echo "─────────────────────────────────────────────"
echo ""

# Path info
echo "  Path:        repos/${REPO_NAME}/"

# Current branch
if [[ -d "${submodule_path}/.git" ]] || [[ -f "${submodule_path}/.git" ]]; then
  current_branch=$(cd "${submodule_path}" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
  echo "  Branch:      ${current_branch}"
fi

# SDD location
if [[ -d "${submodule_path}/sdd" ]]; then
  echo "  SDD:         repos/${REPO_NAME}/sdd/ (repo's own)"
  echo "  Agent specs: repos/${REPO_NAME}/sdd/agent-development/agent-specs/"
elif [[ -d "${SDD_ROOT}/fallback-sdd/${REPO_NAME}" ]]; then
  echo "  SDD:         fallback-sdd/${REPO_NAME}/ (hub fallback)"
  echo "  Agent specs: fallback-sdd/${REPO_NAME}/agent-development/agent-specs/"
else
  echo "  SDD:         ✗ Not configured (run bootstrap or create fallback)"
fi

# Documentation
if [[ -d "${SDD_ROOT}/documentation/${REPO_NAME}" ]]; then
  echo "  Docs:        documentation/${REPO_NAME}/"
fi

# Contracts
if [[ -d "${SDD_ROOT}/contracts/${REPO_NAME}" ]]; then
  echo "  Contracts:   contracts/${REPO_NAME}/"
fi

echo ""
echo "  Common specs: common-specs/"
echo "  Topology:     architectural-schemas/system-overview.md"
echo ""
log_info "To work in this repo: cd repos/${REPO_NAME}"
