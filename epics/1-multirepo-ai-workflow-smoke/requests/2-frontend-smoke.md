---
id: 2
epic_id: 1
title: "Validate frontend dispatch after API dependency completion"
status: refined
repo: "sdd-test-frontend"
depends_on: [1]
complexity: 2
jira_ticket: null
---

# Request: Validate frontend dispatch after API dependency completion

## Goal

Verify that dependency guardrails block task 2 until task 1 is complete, and then allow dispatch to `sdd-test-frontend` once plan 1 is merged.

## Requirements

- Plan dependency check must fail/blocked while task 1 is incomplete.
- After task 1 completion, plan 2 can be merged and dispatch to frontend repo.
- Child repo opens execution branch and draft PR after successful dispatch.

## Acceptance Criteria

- IF task 1 is not done, the system SHALL prevent task 2 progression with a dependency-blocked status/check.
- WHEN task 1 becomes done and plan 2 is merged, the system SHALL dispatch `task-assigned` to `ecarrizo2/sdd-test-frontend`.
- WHEN the child repo receives task 2 dispatch, THEN a frontend execution branch and draft PR are created.
