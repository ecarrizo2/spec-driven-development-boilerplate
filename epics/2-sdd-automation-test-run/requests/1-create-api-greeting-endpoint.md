---
id: 1
title: "Create API greeting endpoint"
status: draft
complexity: 3
jira_ticket: null
epic: "../epic.md"
depends_on: []
created: 2026-06-10
last_updated: 2026-06-10
api_checkpoint: true
---

# Task 1: Create API greeting endpoint

## Goal

Expose `GET /get` that returns `{ "name": "world" }`.

## Context

This establishes the contract consumed by the frontend task.

## Requirements

- **R1.** Add route `GET /get`.
- **R2.** Return JSON payload with `name`.
- **R3.** Keep run path compatible with existing scripts.

## Implementation Details

> ⚠️ **Shell — to be expanded during refinement.** Focus on entrypoint route wiring and contract stability.

## Edge Cases

- To be identified during refinement.

## Deliverables

- [ ] API endpoint implemented
- [ ] Response contract verified

## Acceptance Criteria

- [ ] WHEN `GET /get` is called, the system SHALL return `200 OK` with `{ "name": "world" }`.
- [ ] IF the route is unavailable, the service SHALL fail clearly during verification.
- [ ] WHEN the service starts, the route SHALL be reachable.

## Agent Checklist

- [ ] All tests pass (`bin/dev test`)
- [ ] Lint passes (`bin/dev lint`)
- [ ] Type-check passes (`bin/dev typecheck`)
- [ ] Spec/doc updates included if interfaces changed
- [ ] Hub task-graph updated (status → done)
- [ ] Hub delivery.yaml updated (PR URL added)
