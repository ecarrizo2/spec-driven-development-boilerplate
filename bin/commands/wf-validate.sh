#!/usr/bin/env bash
# bin/dev wf:validate [files...] — Validate YAML manifests and frontmatter
# ─────────────────────────────────────────────────────────────────────────────
# Checks that required fields are non-null and statuses are valid values.
# If no files specified, validates all manifests in sdd/.
# Exit code 1 if any validation fails (for use in git hooks).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

sdd_dir="$(get_sdd_dir)"
errors=0
files_checked=0

# Valid status values
VALID_EPIC_STATUSES="draft discussing decomposed active paused renegotiating delivered done abandoned"
VALID_TASK_STATUSES="draft refined activated planned approved in-progress blocked done skipped"
VALID_PLAN_STATUSES="draft pending-approval approved in-progress done failed paused"
VALID_STAGE_STATUSES="todo in-progress done skipped failed"
VALID_DELIVERY_STATUSES="planned branched draft-pr in-progress ready-for-review merged abandoned"
VALID_REQUEST_STATUSES="draft refined activated planned done"
VALID_APPROVAL_STATUSES="pending approved changes-requested"

# ─────────────────────────────────────────────────────────────────────────────
# Validation helpers
# ─────────────────────────────────────────────────────────────────────────────

validate_status() {
  local file="$1" field_value="$2" valid_values="$3" context="$4"
  if [[ -z "${field_value}" || "${field_value}" == "null" ]]; then
    return 0  # Empty is OK (not yet set)
  fi
  if ! echo "${valid_values}" | grep -qw "${field_value}"; then
    log_error "${file}: invalid ${context} status '${field_value}'"
    log_error "  Valid values: ${valid_values}"
    ((errors++))
    return 1
  fi
  return 0
}

validate_required_field() {
  local file="$1" field_name="$2" field_value="$3"
  if [[ -z "${field_value}" || "${field_value}" == "null" || "${field_value}" == '""' ]]; then
    log_error "${file}: required field '${field_name}' is empty or null"
    ((errors++))
    return 1
  fi
  return 0
}

# ─────────────────────────────────────────────────────────────────────────────
# File validators
# ─────────────────────────────────────────────────────────────────────────────

validate_manifest_yaml() {
  local file="$1"
  ((files_checked++))
  log_info "Validating: ${file}"

  # Check plan status
  local status
  status=$(read_yaml_nested "${file}" "plan_metadata" "status")
  validate_status "${file}" "${status}" "${VALID_PLAN_STATUSES}" "plan"

  # If status is not draft, task_name should be set
  if [[ "${status}" != "draft" && "${status}" != "" ]]; then
    local task_name
    task_name=$(read_yaml_nested "${file}" "plan_metadata" "task_name")
    validate_required_field "${file}" "plan_metadata.task_name" "${task_name}"
  fi
}

validate_delivery_yaml() {
  local file="$1"
  ((files_checked++))
  log_info "Validating: ${file}"

  # Check each node status (if nodes exist)
  while IFS= read -r line; do
    if echo "${line}" | grep -q "status:"; then
      local node_status
      node_status=$(echo "${line}" | sed 's/^.*status:[[:space:]]*//' | sed 's/[[:space:]]*#.*//')
      validate_status "${file}" "${node_status}" "${VALID_DELIVERY_STATUSES}" "delivery node"
    fi
  done < "${file}"
}

validate_frontmatter_md() {
  local file="$1"
  ((files_checked++))

  # Check if file has frontmatter
  if ! head -1 "${file}" | grep -q "^---$"; then
    return 0  # No frontmatter, skip
  fi

  log_info "Validating frontmatter: ${file}"
  local frontmatter
  frontmatter="$(extract_frontmatter "${file}")"

  # Detect file type by path and validate accordingly
  case "${file}" in
    */epic.md)
      local status
      status=$(read_frontmatter_field "${file}" "status")
      validate_status "${file}" "${status}" "${VALID_EPIC_STATUSES}" "epic"
      ;;
    */task-graph.md)
      # Validate each task status in the frontmatter
      local frontmatter
      frontmatter="$(extract_frontmatter "${file}")"
      echo "${frontmatter}" | grep "status:" | sed 's/^.*status:[[:space:]]*//' | sed 's/[[:space:]]*#.*//' | while IFS= read -r ts; do
        validate_status "${file}" "${ts}" "${VALID_TASK_STATUSES}" "task"
      done
      ;;
    */_TEMPLATE-*)
      # Skip templates
      ;;
    */pending/*.md|*/requests/*.md)
      local status
      status=$(read_frontmatter_field "${file}" "status")
      validate_status "${file}" "${status}" "${VALID_REQUEST_STATUSES}" "request"
      ;;
    */specification.md)
      local status
      status=$(read_frontmatter_field "${file}" "status")
      validate_status "${file}" "${status}" "${VALID_PLAN_STATUSES}" "plan"
      ;;
  esac
}

# ─────────────────────────────────────────────────────────────────────────────
# Main logic
# ─────────────────────────────────────────────────────────────────────────────

if [[ $# -gt 0 ]]; then
  # Validate specific files
  for file in "$@"; do
    if [[ ! -f "${file}" ]]; then
      log_warn "File not found: ${file}"
      continue
    fi
    case "${file}" in
      */manifest.yaml) validate_manifest_yaml "${file}" ;;
      */delivery.yaml) validate_delivery_yaml "${file}" ;;
      *.md) validate_frontmatter_md "${file}" ;;
      *.yaml|*.yml) validate_delivery_yaml "${file}" ;;  # Generic YAML validation
    esac
  done
else
  # Validate all manifests in sdd/
  log_step "Validating all SDD manifests..."
  echo ""

  # Plan manifests
  for manifest in "${sdd_dir}"/agent-development/plans/*/manifest.yaml; do
    [[ -f "${manifest}" ]] || continue
    validate_manifest_yaml "${manifest}"
  done

  # Delivery manifests
  for delivery in "${sdd_dir}"/epics/active/*/delivery.yaml; do
    [[ -f "${delivery}" ]] || continue
    validate_delivery_yaml "${delivery}"
  done

  # Epic frontmatter
  for epic in "${sdd_dir}"/epics/active/*/epic.md; do
    [[ -f "${epic}" ]] || continue
    validate_frontmatter_md "${epic}"
  done

  # Task-graph frontmatter
  for tg in "${sdd_dir}"/epics/active/*/task-graph.md; do
    [[ -f "${tg}" ]] || continue
    validate_frontmatter_md "${tg}"
  done

  # Request frontmatter
  for req in "${sdd_dir}"/agent-development/pending/*.md; do
    [[ -f "${req}" ]] || continue
    [[ "$(basename "${req}")" == "_TEMPLATE-request.md" ]] && continue
    validate_frontmatter_md "${req}"
  done

  # Specification frontmatter
  for spec in "${sdd_dir}"/agent-development/plans/*/specification.md; do
    [[ -f "${spec}" ]] || continue
    validate_frontmatter_md "${spec}"
  done
fi

echo ""
if [[ ${errors} -eq 0 ]]; then
  log_success "Validation passed (${files_checked} files checked, 0 errors)"
  exit 0
else
  log_error "Validation failed (${files_checked} files checked, ${errors} errors)"
  exit 1
fi
