---
id: 2
title: "Cross-repo automation test run"
status: draft
complexity: 5
created: 2026-06-10
last_updated: 2026-06-10
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
  contracts: []
  architectural_schemas: []
  other: []
---

# Epic: Cross-repo automation test run

## Problem Statement

We need one clean end-to-end epic to validate the hub automation flow across API and frontend repos.

## Product Vision

The API returns a greeting payload and the frontend renders it, proving cross-repo dispatch and delivery tracking works.

## Requirements

- **R1.** API exposes `GET /get` returning `{ "name": "world" }`.
- **R2.** Frontend fetches API data and renders `Hello, world`.
- **R3.** The full hub workflow can execute and be reviewed through PRs.

## Success Criteria

- [ ] WHEN a client calls `GET /get`, the system SHALL return `200 OK` with JSON `{ "name": "world" }`.
- [ ] GIVEN the API response contains `name: "world"` WHEN the frontend page loads THEN it renders `Hello, world`.
- [ ] GIVEN both tasks are merged WHEN workflow automation runs THEN delivery statuses are updated without manual fixes.

## Scope Boundaries

### In Scope

- Greeting endpoint in API repo
- Greeting fetch/render in frontend repo
- End-to-end automation validation

### Out of Scope

- Authentication
- Database/storage work
- Additional product features

## Repos Involved

| Repo | Role in this epic | Type of changes |
|------|-------------------|-----------------|
| `sdd-test-api` | Greeting API producer | Endpoint implementation |
| `sdd-test-frontend` | Greeting consumer | UI fetch/render and error handling |

## Technical Constraints

- Keep API response shape stable.
- Keep frontend API base configuration environment-friendly.
- Use existing workflow conventions.

## Cross-Repo Dependencies

- Frontend task depends on API contract task completion.

## Decisions Made During Discovery

| # | Question | Decision | Rationale |
|---|---|---|---|
| 1 | What is the API contract? | `GET /get` → `{ "name": "world" }` | Simple deterministic smoke test |
| 2 | What proves frontend success? | Render `Hello, world` | Confirms live API integration |

## Definition of Done

- [ ] API task merged
- [ ] Frontend task merged
- [ ] Delivery manifest reflects merged PRs
- [ ] End-to-end automation run is successful

## References

- `epics/2-sdd-automation-test-run/task-graph.md`
