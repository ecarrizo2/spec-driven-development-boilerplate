#!/usr/bin/env bash
# bin/dev repo:migrate <name> — Move fallback-sdd/ into child repo, create PR
set -euo pipefail

# Hub root (where config/, repos/, epics/ live)
SDD_ROOT="${SDD_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

REPO_NAME="${1:-}"

if [[ -z "${REPO_NAME}" ]]; then
  log_error "Usage: bin/dev repo:migrate <name>"
  echo ""
  echo "  Moves fallback-sdd/<name>/ into repos/<name>/sdd/"
  echo "  Creates a chore branch and prepares a PR in the child repo"
  exit 1
fi

cd "${SDD_ROOT}"

# Validate
if [[ ! -d "fallback-sdd/${REPO_NAME}" ]]; then
  log_error "No fallback-sdd/${REPO_NAME}/ found — nothing to migrate"
  exit 1
fi

if [[ ! -d "repos/${REPO_NAME}" ]]; then
  log_error "Submodule repos/${REPO_NAME} not found — sync first"
  exit 1
fi

if [[ -d "repos/${REPO_NAME}/sdd" ]]; then
  log_error "repos/${REPO_NAME}/sdd/ already exists — repo already has SDD"
  exit 1
fi

log_step "Migrating fallback-sdd/${REPO_NAME}/ → repos/${REPO_NAME}/sdd/"

# Create branch in child repo
cd "repos/${REPO_NAME}"
BRANCH_NAME="chore/adopt-sdd"
git checkout -b "${BRANCH_NAME}"

# Copy fallback structure
cp -r "${SDD_ROOT}/fallback-sdd/${REPO_NAME}" "./sdd"

log_step "Created sdd/ directory in ${REPO_NAME}"

# Stage and commit
git add sdd/
GIT_EDITOR=true git commit -m "chore: adopt SDD boilerplate structure

Migrated from hub's fallback-sdd/${REPO_NAME}/ into repo's own sdd/ directory.
This enables spec-driven development workflow directly within this repository."

log_step "Committed SDD structure on branch '${BRANCH_NAME}'"

# Return to hub
cd "${SDD_ROOT}"

# Remove fallback
rm -rf "fallback-sdd/${REPO_NAME}"
log_step "Removed fallback-sdd/${REPO_NAME}/"

echo ""
log_success "✓ Migration complete"
log_info "Next steps:"
echo "  1. cd repos/${REPO_NAME}"
echo "  2. Push the branch: git push -u origin ${BRANCH_NAME}"
echo "  3. Create a PR (or use: gh pr create --draft)"
echo "  4. Update config/repos.yaml: set has_own_sdd: true"
echo "  5. Commit the hub changes (removed fallback, updated repos.yaml)"
