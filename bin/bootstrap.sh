#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# bin/bootstrap.sh — One-command setup for bin/dev in a new project
# ─────────────────────────────────────────────────────────────────────────────
# Run from repo root: bash sdd/bin/bootstrap.sh
# Prerequisites: bash 4+, git, gh (optional, for PR commands)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}"
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│  bin/dev Bootstrap — SDD Agent CLI Setup                    │"
echo "└─────────────────────────────────────────────────────────────┘"
echo -e "${RESET}"

# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Verify prerequisites
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[1/6]${RESET} Checking prerequisites..."

# Bash version
bash_version="${BASH_VERSINFO[0]}"
if [[ ${bash_version} -lt 4 ]]; then
  echo -e "${RED}✗${RESET} Bash 4+ required (found: ${BASH_VERSION})"
  echo "  macOS: brew install bash"
  exit 1
fi
echo -e "  ${GREEN}✓${RESET} Bash ${BASH_VERSION}"

# Git
if command -v git &>/dev/null; then
  echo -e "  ${GREEN}✓${RESET} Git $(git --version | sed 's/git version //')"
else
  echo -e "  ${RED}✗${RESET} Git not found"
  exit 1
fi

# gh CLI (optional)
if command -v gh &>/dev/null; then
  echo -e "  ${GREEN}✓${RESET} GitHub CLI $(gh --version | head -1 | sed 's/gh version //' | sed 's/ .*//')"
else
  echo -e "  ${YELLOW}⚠${RESET} GitHub CLI not found (PR commands will not work)"
  echo "    Install: https://cli.github.com/"
fi

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Step 2: Detect project structure
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[2/6]${RESET} Detecting project structure..."

# Find project root (where sdd/ should live)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# If running from sdd/bin/, go up two levels
if [[ "$(basename "$(dirname "${SCRIPT_DIR}")")" == "sdd" ]]; then
  PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
else
  PROJECT_ROOT="$(pwd)"
fi

SDD_DIR="${PROJECT_ROOT}/sdd"
BIN_DIR="${SDD_DIR}/bin"
CONFIG_DIR="${SDD_DIR}/config"

if [[ ! -d "${SDD_DIR}" ]]; then
  echo -e "  ${RED}✗${RESET} sdd/ directory not found at ${PROJECT_ROOT}"
  echo "    Make sure you're running from the repo root or that sdd/ exists."
  exit 1
fi
echo -e "  ${GREEN}✓${RESET} SDD directory: ${SDD_DIR}"

# Detect package manager
pkg_manager=""
if [[ -f "${PROJECT_ROOT}/pnpm-lock.yaml" ]]; then
  pkg_manager="pnpm"
elif [[ -f "${PROJECT_ROOT}/yarn.lock" ]]; then
  pkg_manager="yarn"
elif [[ -f "${PROJECT_ROOT}/bun.lockb" ]]; then
  pkg_manager="bun"
elif [[ -f "${PROJECT_ROOT}/package-lock.json" ]]; then
  pkg_manager="npm"
fi

if [[ -n "${pkg_manager}" ]]; then
  echo -e "  ${GREEN}✓${RESET} Package manager: ${pkg_manager}"
else
  echo -e "  ${YELLOW}⚠${RESET} No lock file found — defaulting to npm"
  pkg_manager="npm"
fi

# Detect available scripts from package.json
pkg_json="${PROJECT_ROOT}/package.json"
if [[ -f "${pkg_json}" ]]; then
  echo -e "  ${GREEN}✓${RESET} package.json found"
else
  echo -e "  ${YELLOW}⚠${RESET} No package.json found — you'll need to configure commands manually"
fi

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Step 3: Create/update commands.yaml
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[3/6]${RESET} Configuring commands..."

commands_file="${CONFIG_DIR}/commands.yaml"
mkdir -p "${CONFIG_DIR}"

if [[ -f "${commands_file}" ]]; then
  echo -e "  ${GREEN}✓${RESET} commands.yaml already exists — skipping"
else
  # Auto-detect commands from package.json scripts
  build_cmd="${pkg_manager} run build"
  lint_cmd="${pkg_manager} run lint"
  lint_fix_cmd="${pkg_manager} run lint -- --fix"
  typecheck_cmd="${pkg_manager} run typecheck"
  test_cmd="${pkg_manager} test"
  test_cov_cmd="${pkg_manager} test -- --coverage"

  if [[ -f "${pkg_json}" ]]; then
    # Try to detect better commands from scripts
    if grep -q '"build"' "${pkg_json}"; then
      build_cmd="${pkg_manager} run build"
    fi
    if grep -q '"lint"' "${pkg_json}"; then
      lint_cmd="${pkg_manager} run lint"
    fi
    if grep -q '"lint-nofix"' "${pkg_json}"; then
      lint_cmd="${pkg_manager} run lint-nofix"
      lint_fix_cmd="${pkg_manager} run lint"
    fi
    if grep -q '"tscheck"' "${pkg_json}"; then
      typecheck_cmd="${pkg_manager} run tscheck"
    elif grep -q '"typecheck"' "${pkg_json}"; then
      typecheck_cmd="${pkg_manager} run typecheck"
    fi
    if grep -q '"test:cov"' "${pkg_json}"; then
      test_cov_cmd="${pkg_manager} run test:cov"
    fi
  fi

  cat > "${commands_file}" <<EOF
# sdd/config/commands.yaml
# Maps bin/dev commands to project-specific implementations.
# Auto-generated by bootstrap.sh — edit as needed.

package_manager: ${pkg_manager}

commands:
  build: "${build_cmd}"
  lint: "${lint_cmd}"
  lint_fix: "${lint_fix_cmd}"
  typecheck: "${typecheck_cmd}"
  test: "${test_cmd}"
  test_cov: "${test_cov_cmd}"

  # Uncomment if your project uses Prisma:
  # prisma_gen: "${pkg_manager} run prisma:generate"
  # prisma_migrate: "${pkg_manager} run prisma:migrate:dev --name"

verify_rules:
  markdown_only:
    pattern: "*.md"
    commands: []
  test_files:
    pattern: "*.spec.ts,*.test.ts,*.spec.js,*.test.js"
    commands: [test]
  source_code:
    pattern: "*.ts,*.tsx,*.js,*.jsx"
    commands: [lint, typecheck, test]
  config_files:
    pattern: "*.json,*.yaml,*.yml"
    commands: [typecheck]
EOF

  echo -e "  ${GREEN}✓${RESET} Created: ${commands_file}"
  echo -e "  ${YELLOW}⚠${RESET} Review and adjust the detected commands"
fi

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Step 4: Set permissions
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[4/6]${RESET} Setting permissions..."

chmod +x "${BIN_DIR}/dev" 2>/dev/null && echo -e "  ${GREEN}✓${RESET} bin/dev" || echo -e "  ${YELLOW}⚠${RESET} bin/dev (already executable or not found)"

for cmd_file in "${BIN_DIR}/commands"/*.sh; do
  [[ -f "${cmd_file}" ]] || continue
  chmod +x "${cmd_file}"
done
echo -e "  ${GREEN}✓${RESET} All command scripts"

for hook_file in "${BIN_DIR}/hooks"/*; do
  [[ -f "${hook_file}" ]] || continue
  chmod +x "${hook_file}"
done
echo -e "  ${GREEN}✓${RESET} Hook scripts"

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Step 5: Configure git hooks
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[5/6]${RESET} Configuring git hooks..."

if [[ -f "${PROJECT_ROOT}/lefthook.yml" ]]; then
  echo -e "  ${GREEN}✓${RESET} Lefthook detected"
  echo -e "  ${YELLOW}ℹ${RESET} Add the following to your lefthook.yml:"
  echo ""
  echo "    pre-commit:"
  echo "      commands:"
  echo "        validate-sdd:"
  echo "          glob: 'sdd/**/*.{yaml,yml,md}'"
  echo "          run: bash sdd/bin/hooks/pre-commit"
  echo ""
  echo "    commit-msg:"
  echo "      commands:"
  echo "        conventional-commit:"
  echo "          run: bash sdd/bin/hooks/commit-msg {1}"
  echo ""
elif [[ -d "${PROJECT_ROOT}/.husky" ]]; then
  echo -e "  ${GREEN}✓${RESET} Husky detected"
  echo -e "  ${YELLOW}ℹ${RESET} Run these commands to add hooks:"
  echo "    npx husky add .husky/pre-commit 'bash sdd/bin/hooks/pre-commit'"
  echo "    npx husky add .husky/commit-msg 'bash sdd/bin/hooks/commit-msg \$1'"
  echo ""
else
  echo -e "  ${YELLOW}⚠${RESET} No hook manager detected (lefthook/husky)"
  echo -e "  ${YELLOW}ℹ${RESET} Recommended: install lefthook"
  echo "    ${pkg_manager} add -D lefthook"
  echo "    npx lefthook install"
  echo ""
  echo "  Then add to lefthook.yml:"
  echo "    pre-commit:"
  echo "      commands:"
  echo "        validate-sdd:"
  echo "          glob: 'sdd/**/*.{yaml,yml,md}'"
  echo "          run: bash sdd/bin/hooks/pre-commit"
  echo ""
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 6: Add gitignore entries
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BLUE}[6/6]${RESET} Checking .gitignore..."

gitignore="${PROJECT_ROOT}/.gitignore"
entries_to_add=()

if [[ -f "${gitignore}" ]]; then
  if ! grep -q ".agent-audit-log" "${gitignore}"; then
    entries_to_add+=("sdd/.agent-audit-log")
  fi
else
  entries_to_add+=("sdd/.agent-audit-log")
fi

if [[ ${#entries_to_add[@]} -gt 0 ]]; then
  echo "" >> "${gitignore}"
  echo "# SDD Agent CLI" >> "${gitignore}"
  for entry in "${entries_to_add[@]}"; do
    echo "${entry}" >> "${gitignore}"
  done
  echo -e "  ${GREEN}✓${RESET} Added to .gitignore: ${entries_to_add[*]}"
else
  echo -e "  ${GREEN}✓${RESET} .gitignore already configured"
fi

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Done!
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}─────────────────────────────────────────────────────────────${RESET}"
echo -e "${GREEN}✓ Bootstrap complete!${RESET}"
echo ""
echo "Next steps:"
echo "  1. Review sdd/config/commands.yaml — adjust detected commands"
echo "  2. Configure git hooks (see instructions above)"
echo "  3. Test: sdd/bin/dev help"
echo "  4. Add to your AGENTS.md or agent-instructions.md:"
echo "     'All agent operations MUST go through bin/dev'"
echo ""
echo -e "Run ${BOLD}sdd/bin/dev help${RESET} to see all available commands."
