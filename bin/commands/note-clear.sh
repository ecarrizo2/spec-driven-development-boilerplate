#!/usr/bin/env bash
# bin/dev note:clear — Archive and clear notes
# ─────────────────────────────────────────────────────────────────────────────
# Moves current notes to an archive file and resets .agent-notes.
# This is a human action — agents should not call this.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

sdd_dir="$(get_sdd_dir)"
notes_file="${sdd_dir}/.agent-notes"
archive_file="${sdd_dir}/.agent-notes-archive"

if [[ ! -f "${notes_file}" ]]; then
  log_info "No agent notes to clear."
  exit 0
fi

# Count existing notes
note_count=$(grep -c "^\[" "${notes_file}" 2>/dev/null || echo "0")

if [[ ${note_count} -eq 0 ]]; then
  log_info "No notes to archive (file exists but has no entries)."
  exit 0
fi

# Append to archive with a separator
echo "" >> "${archive_file}"
echo "# ─── Archived $(date -u +"%Y-%m-%d") (${note_count} notes) ───" >> "${archive_file}"
grep "^\[" "${notes_file}" >> "${archive_file}"

# Reset notes file
cat > "${notes_file}" <<'HEADER'
# Agent Notes
# ─────────────────────────────────────────────────────────────────────────────
# Discoveries, suggestions, and friction points recorded by agents.
# Reviewed by humans on cadence. Use `bin/dev note:clear` to archive.
# ─────────────────────────────────────────────────────────────────────────────

HEADER

log_success "Archived ${note_count} notes to .agent-notes-archive"
log_info "Notes file has been reset."
