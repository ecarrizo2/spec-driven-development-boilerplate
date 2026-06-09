---
# ─────────────────────────────────────────────────────────────────────────────
# Request Metadata (machine-parseable)
# ─────────────────────────────────────────────────────────────────────────────
id: 2
title: "Create greeting frontend page"
status: draft
complexity: 3
target_repo: "sdd-test-frontend"
hub_epic: "1-sdd-test-greeting-smoke"
created: 2026-06-09
last_updated: 2026-06-09
discovered_during: null
api_checkpoint: false
depends_on: [1]
---

# Task 2: Create greeting frontend page

## Goal

Create a React page that loads the greeting payload from the API and renders the resulting message to the user.

## Context

The frontend repo is currently a minimal React scaffold. This task consumes the API contract defined in Task 1 and turns it into a visible end-to-end smoke path.

**Parent epic:** `epics/1-sdd-test-greeting-smoke/epic.md`
**Target repo:** `sdd-test-frontend` (from `config/repos.yaml`)

## Requirements

- **R1.** Fetch the greeting payload from the API when the page loads.
- **R2.** Render the greeting text from the API response on the page.
- **R3.** Show a visible error state if the API request fails.

## Cross-Repo Context

This task consumes the API contract established by Task 1.

- Depends on: Task 1 in `sdd-test-api` (greeting contract and endpoint)
- Consumed by: End-to-end smoke test in the hub automation flow
- Contracts to honor: The epic's declared `GET /get` contract

## Implementation Details

> ⚠️ **Shell — to be expanded during refinement.** General approach:
> - Add the page/component wiring that fetches the greeting on load.
> - Keep the API target configurable for local development and CI.
> - Key files likely involved: React app entrypoint, page/component files, package scripts, README.

## Deliverables

- [ ] Greeting page implemented
- [ ] The page renders API data and handles failure state
- [ ] Epic and task artifacts remain the source of truth for the cross-repo contract

## Acceptance Criteria

- [ ] GIVEN the API returns `{ "name": "world" }` WHEN the frontend page loads, THEN the page SHALL render `Hello, world`.
- [ ] WHEN the page cannot reach the API, the system SHALL show a visible error state.
- [ ] WHEN the page loads successfully, the frontend SHALL request the greeting endpoint defined in the contract.

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
