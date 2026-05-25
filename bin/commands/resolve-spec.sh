#!/usr/bin/env bash
# bin/dev resolve-spec <type> <repo> — Find spec file using cascade rules
set -euo pipefail

# Hub root (where config/, repos/, epics/ live)
SDD_ROOT="${SDD_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

SPEC_TYPE="${1:-}"
REPO_NAME="${2:-}"

if [[ -z "${SPEC_TYPE}" ]] || [[ -z "${REPO_NAME}" ]]; then
  log_error "Usage: bin/dev resolve-spec <type> <repo>"
  echo ""
  echo "  Types: architecture, overview, git-workflow, agent-instructions, agent-workflow"
  echo ""
  echo "  Example: bin/dev resolve-spec architecture awards-api"
  echo "  Returns the path to the correct spec file using the cascade:"
  echo "    1. repos/<repo>/sdd/agent-specs/"
  echo "    2. fallback-sdd/<repo>/agent-specs/"
  echo "    3. documentation/<repo>/"
  echo "    4. common-specs/"
  exit 1
fi

cd "${SDD_ROOT}"

# Map type to filename patterns
case "${SPEC_TYPE}" in
  architecture)
    repo_paths=(
      "repos/${REPO_NAME}/sdd/agent-development/agent-specs/architecture-breakdown.md"
      "fallback-sdd/${REPO_NAME}/agent-development/agent-specs/architecture-breakdown.md"
      "documentation/${REPO_NAME}/architecture.md"
    )
    ;;
  overview)
    repo_paths=(
      "repos/${REPO_NAME}/sdd/agent-development/agent-specs/application-overview.md"
      "fallback-sdd/${REPO_NAME}/agent-development/agent-specs/application-overview.md"
      "documentation/${REPO_NAME}/overview.md"
    )
    ;;
  git-workflow)
    repo_paths=(
      "repos/${REPO_NAME}/sdd/agent-development/agent-specs/git-workflow.md"
      "fallback-sdd/${REPO_NAME}/agent-development/agent-specs/git-workflow.md"
      "common-specs/git-workflow.md"
    )
    ;;
  agent-instructions)
    repo_paths=(
      "repos/${REPO_NAME}/sdd/agent-development/agent-specs/agent-instructions.md"
      "fallback-sdd/${REPO_NAME}/agent-development/agent-specs/agent-instructions.md"
      "common-specs/sdd-process.md"
    )
    ;;
  agent-workflow)
    repo_paths=(
      "repos/${REPO_NAME}/sdd/agent-development/agent-specs/agent-workflow.md"
      "fallback-sdd/${REPO_NAME}/agent-development/agent-specs/agent-workflow.md"
      "common-specs/sdd-process.md"
    )
    ;;
  *)
    log_error "Unknown spec type: ${SPEC_TYPE}"
    echo "  Valid types: architecture, overview, git-workflow, agent-instructions, agent-workflow"
    exit 1
    ;;
esac

# Walk the cascade
for path in "${repo_paths[@]}"; do
  if [[ -f "${path}" ]]; then
    echo "${path}"
    exit 0
  fi
done

log_error "No spec found for type '${SPEC_TYPE}' in repo '${REPO_NAME}'"
echo "  Searched:"
for path in "${repo_paths[@]}"; do
  echo "    ✗ ${path}"
done
exit 1
