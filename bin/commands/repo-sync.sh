#!/usr/bin/env bash
# bin/dev repo:sync [name] — Update submodule(s) to latest main branch
set -euo pipefail

# Hub root (where config/, repos/, epics/ live)
SDD_ROOT="${SDD_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

REPO_NAME="${1:-}"

if [[ -n "${REPO_NAME}" ]]; then
  # Sync a specific repo
  submodule_path="repos/${REPO_NAME}"
  if [[ ! -d "${SDD_ROOT}/${submodule_path}" ]]; then
    log_error "Repo '${REPO_NAME}' not found at ${submodule_path}"
    log_info "Run 'bin/dev repo:list' to see registered repos"
    exit 1
  fi

  log_step "Syncing ${REPO_NAME}..."
  cd "${SDD_ROOT}"
  git submodule update --init --remote "${submodule_path}"
  log_success "✓ ${REPO_NAME} synced to latest"
else
  # Sync all repos
  log_step "Syncing all submodules to latest main..."
  cd "${SDD_ROOT}"
  git submodule update --init --remote
  log_success "✓ All repos synced"
fi
