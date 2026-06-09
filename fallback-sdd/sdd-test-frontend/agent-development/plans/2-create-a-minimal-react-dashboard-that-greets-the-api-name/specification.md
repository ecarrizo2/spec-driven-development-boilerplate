---
id: 2
epic_id: 2
title: "Create a minimal React dashboard that greets the API name"
status: refined
repo: "sdd-test-frontend"
depends_on: [1]
complexity: 2
jira_ticket: null
---

# Request: Create a minimal React dashboard that greets the API name

## Goal

Generate a clean React MVP that fetches the API name and shows a centered greeting.

## Requirements

- Fetch the API response on load.
- Display `Hi, {name}` using the `name` returned by the API.
- Keep the page clean and minimal with no extra dashboard widgets or controls.

## Acceptance Criteria

- WHEN the app loads and the API request succeeds, the UI SHALL render `Hi, {name}`.
- WHEN the greeting renders, the text SHALL be centered on the page.
- IF the API task is not complete, the frontend task SHALL remain blocked by dependency validation.
