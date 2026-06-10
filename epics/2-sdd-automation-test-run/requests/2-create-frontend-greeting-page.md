---
id: 2
title: "Create frontend greeting page"
status: draft
complexity: 3
jira_ticket: null
epic: "../epic.md"
depends_on: [1]
created: 2026-06-10
last_updated: 2026-06-10
api_checkpoint: false
---

# Task 2: Create frontend greeting page

## Goal

Render `Hello, world` from API data.

## Context

Consumes Task 1 API contract in the frontend repo.

## Requirements

- **R1.** Fetch greeting payload from API.
- **R2.** Render `Hello, {name}`.
- **R3.** Show visible error state on request failure.

## Implementation Details

> ⚠️ **Shell — to be expanded during refinement.** Focus on page load fetch behavior and error rendering.

## Edge Cases

- To be identified during refinement.

## Deliverables

- [ ] Greeting page updated
- [ ] API integration verified

## Acceptance Criteria

- [ ] GIVEN API returns `{ "name": "world" }` WHEN page loads THEN it renders `Hello, world`.
- [ ] IF API request fails, the system SHALL display an error state.
- [ ] WHEN API responds successfully, frontend SHALL consume the endpoint contract from Task 1.

## Agent Checklist

- [ ] All tests pass (`bin/dev test`)
- [ ] Lint passes (`bin/dev lint`)
- [ ] Type-check passes (`bin/dev typecheck`)
- [ ] Spec/doc updates included if interfaces changed
- [ ] Hub task-graph updated (status → done)
- [ ] Hub delivery.yaml updated (PR URL added)
