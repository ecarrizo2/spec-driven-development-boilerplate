---
# ─────────────────────────────────────────────────────────────────────────────
# Request Metadata (machine-parseable)
# ─────────────────────────────────────────────────────────────────────────────
id: 1
title: "Create greeting API endpoint"
status: draft
complexity: 3
target_repo: "sdd-test-api"
hub_epic: "1-sdd-test-greeting-smoke"
created: 2026-06-09
last_updated: 2026-06-09
discovered_during: null
api_checkpoint: true
depends_on: []
---

# Task 1: Create greeting API endpoint

## Goal

Create a small API service endpoint that returns a deterministic greeting payload for the frontend to consume.

## Context

The API repo is currently a minimal Node.js scaffold. This task turns it into the source of truth for the greeting contract used by the frontend task.

**Parent epic:** `epics/1-sdd-test-greeting-smoke/epic.md`
**Target repo:** `sdd-test-api` (from `config/repos.yaml`)

## Requirements

- **R1.** Expose a greeting endpoint at `GET /get`.
- **R2.** Return `200 OK` with JSON `{ "name": "world" }` for the greeting endpoint.
- **R3.** Keep the service runnable through the repo's documented npm scripts.

## Cross-Repo Context

The frontend task consumes the API contract defined here.

- Depends on: None
- Consumed by: Task 2 in `sdd-test-frontend` (expects the greeting payload)
- Contracts to honor: The epic's declared `GET /get` contract

## Implementation Details

> ⚠️ **Shell — to be expanded during refinement.** General approach:
> - Add or update the API entrypoint and route wiring.
> - Align package scripts and any supporting docs with the new endpoint.
> - Key files likely involved: `package.json`, service entrypoint, route handler, README.

## Deliverables

- [ ] Greeting endpoint implemented
- [ ] Service can be started and returns the expected JSON payload
- [ ] Epic and task artifacts remain the source of truth for the cross-repo contract

## Acceptance Criteria

- [ ] WHEN a client sends `GET /get`, the system SHALL return `200 OK` with JSON `{ "name": "world" }`.
- [ ] WHEN the API service starts, the greeting route SHALL be available without manual setup beyond the repo's documented start command.
- [ ] IF a client requests an unsupported route, the service SHALL behave consistently with the repo's standard error handling.

## Edge Cases

- To be identified during refinement

## Agent Checklist

- [ ] All tests pass (`bin/dev test`)
- [ ] Lint passes (`bin/dev lint`)
- [ ] Type-check passes (`bin/dev typecheck`)
- [ ] Spec/doc updates included if interfaces changed
- [ ] Hub task-graph updated (status → done)
- [ ] Hub delivery.yaml updated (PR URL added)

---

> ⚠️ **This is a request shell.** It will be refined into a full request using Prompt 7 before activation and Jira ticket creation.

> 📁 **Plan location:** When tasks are planned (Prompt 1), plan folders are created in this epic's `plans/` directory — not in `agent-development/plans/`.
