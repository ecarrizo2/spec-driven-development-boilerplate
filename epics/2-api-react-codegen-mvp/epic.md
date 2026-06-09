---
id: 2
title: "API and React Code Generation MVP"
status: pending
complexity: 5
created: 2026-06-09
last_updated: 2026-06-09
owner: "Ezequiel Carrizo"
jira_epic: null
scope:
  repos: ["sdd-test-api", "sdd-test-frontend"]
  primary_repo: "sdd-test-api"
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

# Epic: API and React Code Generation MVP

## Problem Statement

We need a clean end-to-end code generation test that proves the system can generate a minimal API service, then generate a minimal frontend that consumes it and renders a simple UI.

## Product Vision

After the epic is approved, the workflow should create two repo-specific plan PRs, synthesize the plans with AI, and dispatch code generation tasks that result in a working Express API and a React frontend that consumes it.

## Requirements

- **R1.** The API task must produce a minimal Express server that responds to `GET /` with JSON containing a `name` field.
- **R2.** The frontend task must produce a minimal React MVP that fetches the name from the API and renders `Hi, {name}`.
- **R3.** The frontend task must depend on the API task so the system exercises dependency handling.
- **R4.** The generated UI must stay minimal: one centered greeting on a clean page with no extra dashboard widgets or navigation.

## Success Criteria

- [ ] WHEN the API task is executed, the system SHALL generate an Express server that returns `200 OK` with JSON including a `name` field on `GET /`.
- [ ] WHEN the frontend task is executed, the system SHALL generate a React app that fetches the API response and renders `Hi, {name}`.
- [ ] WHEN the frontend app loads successfully, the greeting SHALL be centered on the page and no additional application chrome SHALL be visible.
- [ ] IF the API task is incomplete, the system SHALL keep the frontend task blocked by dependency validation.

## Scope Boundaries

### In Scope

- Minimal API generation for a single endpoint.
- Minimal React UI generation that consumes the API.
- Dependency gating between API and frontend tasks.

### Out of Scope

- Authentication, persistence, routing, or styling systems beyond the centered greeting.
- Extra dashboard panels, charts, or navigation.
- Production deployment or infrastructure changes.

## Repos Involved

| Repo | Role in this epic | Type of changes |
|------|-------------------|-----------------|
| `sdd-test-api` | API generation target | Express server + endpoint |
| `sdd-test-frontend` | Frontend generation target | React MVP + API fetch |

## Technical Constraints

- The API response shape must stay simple enough for the frontend to consume directly.
- The frontend should derive displayed text from the API response rather than hardcoding the final greeting.
- Task graph and request files must stay consumable by the existing SDD workflows.

## Cross-Repo Dependencies

- Task 2 depends on Task 1 so the frontend only proceeds once the API generation is ready.
- The frontend task should assume the API contract is a single JSON object with a `name` field.

## Decisions Made During Discovery

| # | Question | Decision | Rationale |
|---|---|---|---|
| 1 | Should this test be multi-repo? | Yes | We want to validate cross-repo orchestration. |
| 2 | What should the API return? | A hardcoded `name` field | Keeps the contract minimal and easy for the frontend to consume. |
| 3 | What should the frontend render? | `Hi, {name}` centered on a clean page | Smallest useful UI for codegen verification. |

## Definition of Done

- [ ] **Deployment:** Both repo execution PRs are created and merged through the standard workflow.
- [ ] **Monitoring:** The plan pickup and dependency checks complete successfully for both tasks.
- [ ] **Sign-offs:** Human approval is recorded for the epic PR and both plan PRs.
- [ ] **Documentation:** Delivery tracking records the child PR URLs.
- [ ] **Success metrics:** The generated API and frontend satisfy the acceptance criteria above.
- [ ] **Manual steps:** None.

## References

- `.github/workflows/epic-approval.yml`
- `.github/workflows/epic-create-plans.yml`
- `.github/workflows/plan-agent-pickup.yml`
- `.github/workflows/plan-execution-trigger.yml`
