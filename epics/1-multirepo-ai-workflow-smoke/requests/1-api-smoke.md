---
id: 1
epic_id: 1
title: "Validate API dispatch and execution PR creation"
status: refined
repo: "sdd-test-api"
depends_on: []
complexity: 2
jira_ticket: null
---

# Request: Validate API dispatch and execution PR creation

## Goal

Verify that merging the approved plan for task 1 dispatches correctly to `sdd-test-api` and opens an execution branch and draft PR in the child repository.

## Requirements

- Dispatch payload includes valid task metadata, hub reference, and integrity token.
- Child repo reusable receive workflow accepts payload and creates execution branch.
- Child repo opens draft execution PR with hub cross-reference fields.

## Acceptance Criteria

- WHEN plan PR for task 1 is merged, the system SHALL dispatch `task-assigned` to `ecarrizo2/sdd-test-api`.
- WHEN the child repo receives the dispatch, the system SHALL create the execution branch and draft PR.
- IF dispatch payload is invalid or tampered, the system SHALL fail the handoff and report workflow failure.
