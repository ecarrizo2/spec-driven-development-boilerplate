#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# bin/commands/_common.sh — Shared utilities for bin/dev commands
# ─────────────────────────────────────────────────────────────────────────────
# Sourced by bin/dev before dispatching to command scripts.
# Provides logging, config reading, and common helpers.
# ─────────────────────────────────────────────────────────────────────────────

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
  _RED='\033[0;31m'
  _GREEN='\033[0;32m'
  _YELLOW='\033[0;33m'
  _BLUE='\033[0;34m'
  _CYAN='\033[0;36m'
  _BOLD='\033[1m'
  _RESET='\033[0m'
else
  _RED='' _GREEN='' _YELLOW='' _BLUE='' _CYAN='' _BOLD='' _RESET=''
fi

# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────
log_info() {
  echo -e "${_BLUE}ℹ${_RESET} $*"
}

log_success() {
  echo -e "${_GREEN}✓${_RESET} $*"
}

log_warn() {
  echo -e "${_YELLOW}⚠${_RESET} $*" >&2
}

log_error() {
  echo -e "${_RED}✗${_RESET} $*" >&2
}

log_step() {
  echo -e "${_CYAN}→${_RESET} ${_BOLD}$*${_RESET}"
}

# ─────────────────────────────────────────────────────────────────────────────
# YAML reading (lightweight — grep + sed, no external deps)
# ─────────────────────────────────────────────────────────────────────────────

# Read a top-level scalar field from a YAML file.
# Usage: read_yaml_field <file> <field_name>
# Returns the value (stripped of quotes) or empty string if not found.
read_yaml_field() {
  local file="$1" field="$2"
  if [[ ! -f "${file}" ]]; then
    echo ""
    return 1
  fi
  # Match "field: value" or "field: 'value'" or 'field: "value"'
  local value
  value=$(grep -m1 "^${field}:" "${file}" 2>/dev/null | sed "s/^${field}:[[:space:]]*//" | sed 's/^["'\'']//' | sed 's/["'\'']*$//' | sed 's/[[:space:]]*#.*//')
  echo "${value}"
}

# Read a nested field (one level deep) from a YAML file.
# Usage: read_yaml_nested <file> <parent> <field>
# Example: read_yaml_nested teams.yaml "branching" "base_branch" → "main"
read_yaml_nested() {
  local file="$1" parent="$2" field="$3"
  if [[ ! -f "${file}" ]]; then
    echo ""
    return 1
  fi
  local value
  value=$(sed -n "/^${parent}:/,/^[^ ]/p" "${file}" 2>/dev/null | grep -m1 "^[[:space:]]*${field}:" | sed "s/^[[:space:]]*${field}:[[:space:]]*//" | sed 's/^["'\'']//' | sed 's/["'\'']*$//' | sed 's/[[:space:]]*#.*//')
  echo "${value}"
}

# Read a YAML array field as newline-separated values.
# Usage: read_yaml_array <file> <field>
read_yaml_array() {
  local file="$1" field="$2"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  sed -n "/^[[:space:]]*${field}:/,/^[[:space:]]*[^ -]/p" "${file}" 2>/dev/null \
    | grep "^[[:space:]]*-" \
    | sed 's/^[[:space:]]*-[[:space:]]*//' \
    | sed 's/^["'\'']//' | sed 's/["'\'']*$//'
}

# Extract YAML frontmatter from a Markdown file (between --- delimiters).
# Usage: extract_frontmatter <file>
# Outputs the frontmatter content (without the --- delimiters).
extract_frontmatter() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    return 1
  fi
  # macOS-compatible: use awk instead of sed for frontmatter extraction
  awk 'BEGIN{found=0} /^---$/{found++; next} found==1{print} found==2{exit}' "${file}"
}

# Read a field from a Markdown file's YAML frontmatter.
# Usage: read_frontmatter_field <file> <field_name>
read_frontmatter_field() {
  local file="$1" field="$2"
  local frontmatter
  frontmatter="$(extract_frontmatter "${file}")"
  echo "${frontmatter}" | grep -m1 "^${field}:" | sed "s/^${field}:[[:space:]]*//" | sed 's/^["'\'']//' | sed 's/["'\'']*$//' | sed 's/[[:space:]]*#.*//'
}

# ─────────────────────────────────────────────────────────────────────────────
# Config helpers
# ─────────────────────────────────────────────────────────────────────────────

# Get the project root (where sdd/ lives)
get_project_root() {
  echo "${PROJECT_ROOT}"
}

# Get the SDD directory path
get_sdd_dir() {
  echo "${SDD_DIR}"
}

# Get team config file path
get_teams_config_path() {
  echo "${SDD_DIR}/config/teams.yaml"
}

# Get commands config file path
get_commands_config_path() {
  echo "${SDD_DIR}/config/commands.yaml"
}

# Read a command mapping from commands.yaml
# Usage: get_command <command_name>
# Example: get_command "build" → "pnpm run build"
get_command() {
  local cmd_name="$1"
  local config_file
  config_file="$(get_commands_config_path)"
  if [[ ! -f "${config_file}" ]]; then
    log_error "Missing config: ${config_file}"
    log_error "Run 'bin/bootstrap.sh' to set up project commands."
    return 1
  fi
  read_yaml_nested "${config_file}" "commands" "${cmd_name}"
}

# Get the active team name from teams.yaml
get_active_team() {
  local config_file
  config_file="$(get_teams_config_path)"
  read_yaml_field "${config_file}" "active_team"
}

# Get a branching config value
# Usage: get_branching_config <field>
get_branching_config() {
  local field="$1"
  local config_file
  config_file="$(get_teams_config_path)"
  read_yaml_nested "${config_file}" "branching" "${field}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Git helpers
# ─────────────────────────────────────────────────────────────────────────────

# Get the current git branch name
get_current_branch() {
  git branch --show-current 2>/dev/null
}

# Extract ticket ID from a branch name using the configured pattern
# Usage: get_ticket_from_branch [branch_name]
# If no branch name provided, uses current branch.
get_ticket_from_branch() {
  local branch="${1:-$(get_current_branch)}"
  local pattern
  pattern="$(get_branching_config "ticket_id_pattern")"
  if [[ -z "${pattern}" ]]; then
    pattern='[A-Z][A-Z0-9]+-[0-9]+'
  fi
  echo "${branch}" | grep -oE "${pattern}" | head -1
}

# Check if we're on the main/base branch (should not commit here)
is_on_base_branch() {
  local current base
  current="$(get_current_branch)"
  base="$(get_branching_config "base_branch")"
  [[ -z "${base}" ]] && base="main"
  [[ "${current}" == "${base}" || "${current}" == "master" ]]
}

# Get the base branch for PRs
get_base_branch() {
  local base
  base="$(get_branching_config "base_branch")"
  [[ -z "${base}" ]] && base="main"
  echo "${base}"
}

# Get the co-author trailer from teams.yaml
get_co_author() {
  local config_file
  config_file="$(get_teams_config_path)"
  # Navigate: teams.<active_team>.conventions.commit_co_author
  # For simplicity with our lightweight parser, use a direct grep
  grep -m1 "commit_co_author:" "${config_file}" 2>/dev/null \
    | sed 's/^.*commit_co_author:[[:space:]]*//' \
    | sed 's/^["'\'']//' | sed 's/["'\'']*$//'
}

# ─────────────────────────────────────────────────────────────────────────────
# Prerequisite checks
# ─────────────────────────────────────────────────────────────────────────────

# Check that a required tool is installed
# Usage: require_tool <tool_name> [install_hint]
require_tool() {
  local tool="$1"
  local hint="${2:-"Please install ${tool}"}"
  if ! command -v "${tool}" &>/dev/null; then
    log_error "Required tool not found: ${tool}"
    log_error "${hint}"
    return 1
  fi
}

# Check that we're inside a git repository
require_git_repo() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    log_error "Not inside a git repository"
    return 1
  fi
}

# Check that gh CLI is authenticated
require_gh_auth() {
  require_tool "gh" "Install GitHub CLI: https://cli.github.com/"
  if ! gh auth status &>/dev/null 2>&1; then
    log_error "GitHub CLI is not authenticated. Run: gh auth login"
    return 1
  fi
}
