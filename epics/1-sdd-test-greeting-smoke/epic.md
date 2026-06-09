---
id: 1
title: "Cross-repo greeting smoke test"
status: draft
complexity: 5
created: 2026-06-09
last_updated: 2026-06-09
owner: "ezequielcarrizo"
jira_epic: null
scope:
  repos:
    - sdd-test-api
    - sdd-test-frontend
  primary_repo: sdd-test-api
approval:
  approved_by: null
  approved_at: null
references:
  confluence: []
  figma: []
  other:
    - https://github.com/ecarrizo2/sdd-test-api
    - https://github.com/ecarrizo2/sdd-test-frontend
---

# Epic: Cross-repo greeting smoke test

## Problem Statement

The current fork needs a small, reliable cross-repo feature so we can re-run the hub automation path end to end. The backend should provide a deterministic greeting payload and the frontend should consume it and render the result.

## Product Vision

When the epic is complete, the API and frontend will work together as a simple smoke test: a backend greeting endpoint serves the data and the frontend displays it to the user.

## Requirements

- **R1.** The API repo shall expose a stable greeting endpoint that returns the expected JSON payload.
- **R2.** The frontend repo shall fetch that payload and render the greeting on a page.
- **R3.** The cross-repo workflow shall be usable as an automation test for dispatch, verification, and merge tracking.

## Success Criteria

- [ ] WHEN a client sends `GET /get` to the API, the system SHALL return `200 OK` with JSON `{ "name": "world" }`.
- [ ] GIVEN the API returns `{ "name": "world" }` WHEN the frontend page loads, THEN the page SHALL render `Hello, world`.
- [ ] IF the API request fails, the frontend SHALL show a visible error state instead of crashing.
- [ ] GIVEN both repo changes are merged, WHEN the hub automation runs, THEN the cross-repo flow SHALL complete without manual repair.

## Scope Boundaries

### In Scope

- API greeting endpoint
- Frontend page fetch/render
- Cross-repo automation test path
- Contract and coordination docs needed for the handoff

### Out of Scope

- Authentication
- Persistence or database storage
- Visual redesign beyond the greeting page
- Additional product features or extra routes

## Repos Involved

| Repo | Role in this epic | Type of changes |
|------|-------------------|-----------------|
| `sdd-test-api` | Greeting API producer | New endpoint and supporting service code |
| `sdd-test-frontend` | Greeting consumer UI | Page fetch/render and error handling |

## Technical Constraints

- The API response shape must remain stable across the two repos.
- The frontend must be able to target the API in local development and CI without hardcoding environment-specific values.
- The hub workflows must continue to drive task dispatch, verification, and status tracking.

## Cross-Repo Dependencies

- The frontend depends on the API contract defined by the greeting endpoint.
- The API should be verifiable independently before the frontend smoke path is exercised.
- The automation test should preserve the order: dispatch task(s) → implement API → implement frontend → verify end to end.

## Decisions Made During Discovery

| # | Question | Decision | Rationale |
|---|---|---|---|
| 1 | Which repos are in scope? | `sdd-test-api` and `sdd-test-frontend` | Matches the cross-repo test path the user wants to exercise |
| 2 | What does the API return? | `GET /get` returns `{ "name": "world" }` | Deterministic payload keeps the test simple |
| 3 | What does the frontend show? | `Hello, world` on the page | Confirms the frontend is reading live API data |
| 4 | How should failures behave? | Show a visible error state in the frontend | Prevents a silent or crashing failure mode |

## Definition of Done

- [ ] **Deployment:** Both repo changes are merged to their main branches.
- [ ] **Monitoring:** The smoke path can be exercised repeatedly without manual intervention.
- [ ] **Sign-offs:** The end-to-end greeting flow is confirmed by the user.
- [ ] **Documentation:** The epic, task graph, delivery manifest, and request shells are present.
- [ ] **Success metrics:** The greeting flow completes successfully in the automation test run.
- [ ] **Manual steps:** None.

## References

- `contracts/sdd-test-greeting.md`
- `architectural-schemas/system-overview.md`
