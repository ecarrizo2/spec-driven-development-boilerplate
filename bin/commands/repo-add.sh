#!/usr/bin/env bash
# bin/dev repo:add <name> <git-url> — Register a new repo as a submodule
set -euo pipefail

# Hub root (where config/, repos/, epics/ live)
SDD_ROOT="${SDD_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

REPO_NAME="${1:-}"
GIT_URL="${2:-}"

if [[ -z "${REPO_NAME}" ]] || [[ -z "${GIT_URL}" ]]; then
  log_error "Usage: bin/dev repo:add <name> <git-url>"
  echo ""
  echo "  Example: bin/dev repo:add awards-api git@github.com:org/awards-api.git"
  exit 1
fi

cd "${SDD_ROOT}"

# Check if already exists
if [[ -d "repos/${REPO_NAME}" ]]; then
  log_error "Repo '${REPO_NAME}' already exists at repos/${REPO_NAME}"
  exit 1
fi

log_step "Adding ${REPO_NAME} as submodule..."
git submodule add "${GIT_URL}" "repos/${REPO_NAME}"

log_step "Initializing submodule..."
git submodule update --init "repos/${REPO_NAME}"

# Check if repo has its own sdd/
if [[ -d "repos/${REPO_NAME}/sdd" ]]; then
  log_info "✓ Repo has its own sdd/ directory — no fallback needed"
else
  log_info "⚠ Repo does not have sdd/ — creating fallback structure..."
  mkdir -p "fallback-sdd/${REPO_NAME}/agent-development/agent-specs"
  mkdir -p "fallback-sdd/${REPO_NAME}/agent-development/pending"
  mkdir -p "fallback-sdd/${REPO_NAME}/agent-development/plans/_templates"
  mkdir -p "fallback-sdd/${REPO_NAME}/agent-development/done/plans"
  mkdir -p "fallback-sdd/${REPO_NAME}/agent-development/done/requests"
  mkdir -p "fallback-sdd/${REPO_NAME}/agent-development/done/quick-fixes"
  mkdir -p "fallback-sdd/${REPO_NAME}/config"
  touch "fallback-sdd/${REPO_NAME}/agent-development/pending/.gitkeep"
  touch "fallback-sdd/${REPO_NAME}/agent-development/done/plans/.gitkeep"
  touch "fallback-sdd/${REPO_NAME}/agent-development/done/requests/.gitkeep"
  touch "fallback-sdd/${REPO_NAME}/agent-development/done/quick-fixes/.gitkeep"
  log_info "Created fallback-sdd/${REPO_NAME}/ — populate agent-specs with Prompt 0"
fi

echo ""
log_success "✓ ${REPO_NAME} registered successfully"
log_info "Next steps:"
echo "  1. Add repo details to config/repos.yaml"
echo "  2. Run Prompt 0 to generate agent-specs (if using fallback)"
echo "  3. Add documentation to documentation/${REPO_NAME}/"
