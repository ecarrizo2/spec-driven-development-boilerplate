#!/usr/bin/env bash
# bin/dev note:read [n] — Show last N agent notes
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

sdd_dir="$(get_sdd_dir)"
notes_file="${sdd_dir}/.agent-notes"

if [[ ! -f "${notes_file}" ]]; then
  log_info "No agent notes found yet."
  log_info "Create one with: bin/dev note \"your message\""
  exit 0
fi

# Number of lines to show (default: all)
num_lines="${1:-0}"

echo ""
echo -e "${_BOLD}Agent Notes${_RESET}"
echo "─────────────────────────────────────────"

# Filter to only note lines (skip header comments)
notes=$(grep "^\[" "${notes_file}" 2>/dev/null || true)

if [[ -z "${notes}" ]]; then
  log_info "No notes recorded yet."
  exit 0
fi

if [[ ${num_lines} -gt 0 ]]; then
  echo "${notes}" | tail -n "${num_lines}" | while IFS= read -r line; do
    # Colorize by type
    if echo "${line}" | grep -q "\[suggestion\]"; then
      echo -e "${_GREEN}${line}${_RESET}"
    elif echo "${line}" | grep -q "\[friction\]"; then
      echo -e "${_RED}${line}${_RESET}"
    elif echo "${line}" | grep -q "\[question\]"; then
      echo -e "${_YELLOW}${line}${_RESET}"
    else
      echo -e "${_CYAN}${line}${_RESET}"
    fi
  done
else
  echo "${notes}" | while IFS= read -r line; do
    if echo "${line}" | grep -q "\[suggestion\]"; then
      echo -e "${_GREEN}${line}${_RESET}"
    elif echo "${line}" | grep -q "\[friction\]"; then
      echo -e "${_RED}${line}${_RESET}"
    elif echo "${line}" | grep -q "\[question\]"; then
      echo -e "${_YELLOW}${line}${_RESET}"
    else
      echo -e "${_CYAN}${line}${_RESET}"
    fi
  done
fi

echo "─────────────────────────────────────────"
total=$(echo "${notes}" | wc -l | tr -d ' ')
echo -e "Total: ${total} notes"
echo ""
