#!/usr/bin/env bash
# bin/dev note [--type=TYPE] "message" — Record a discovery/suggestion
# ─────────────────────────────────────────────────────────────────────────────
# Types: suggestion, discovery, friction, question
# Notes are committed (part of the repo) and reviewed by humans on cadence.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

sdd_dir="$(get_sdd_dir)"
notes_file="${sdd_dir}/.agent-notes"

# Parse arguments
note_type="discovery"
message=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type=*)
      note_type="${1#--type=}"
      shift
      ;;
    --type)
      shift
      note_type="${1:-discovery}"
      shift
      ;;
    *)
      if [[ -z "${message}" ]]; then
        message="$1"
      else
        message="${message} $1"
      fi
      shift
      ;;
  esac
done

# Validate type
valid_types="suggestion discovery friction question"
if ! echo "${valid_types}" | grep -qw "${note_type}"; then
  log_error "Invalid note type: ${note_type}"
  log_error "Valid types: ${valid_types}"
  exit 1
fi

# Validate message
if [[ -z "${message}" ]]; then
  log_error "Usage: bin/dev note [--type=TYPE] \"message\""
  echo ""
  echo "Types:"
  echo "  suggestion  — A tool, command, or improvement you'd like to exist"
  echo "  discovery   — An undocumented behavior or pattern you found"
  echo "  friction    — Something that slowed you down or felt wrong"
  echo "  question    — Something you couldn't determine from available docs"
  exit 1
fi

# Create notes file if it doesn't exist
if [[ ! -f "${notes_file}" ]]; then
  cat > "${notes_file}" <<'HEADER'
# Agent Notes
# ─────────────────────────────────────────────────────────────────────────────
# Discoveries, suggestions, and friction points recorded by agents.
# Reviewed by humans on cadence. Use `bin/dev note:clear` to archive.
# ─────────────────────────────────────────────────────────────────────────────

HEADER
fi

# Append the note
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
branch="$(get_current_branch 2>/dev/null || echo "unknown")"
echo "[${timestamp}] [${note_type}] [${branch}] ${message}" >> "${notes_file}"

log_success "Note recorded (${note_type}): ${message}"
