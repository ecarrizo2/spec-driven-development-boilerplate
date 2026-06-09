---
id: 1
epic_id: 2
title: "Create a minimal Express hello-world API"
status: refined
repo: "sdd-test-api"
depends_on: []
complexity: 2
jira_ticket: null
---

# Request: Create a minimal Express hello-world API

## Goal

Generate a small Express server that serves a hardcoded JSON response for the frontend to consume.

## Requirements

- Start an Express app that can run locally.
- Respond to `GET /` with JSON containing a `name` field.
- Keep the implementation minimal and easy to consume from a browser client.

## Acceptance Criteria

- WHEN a `GET /` request is sent, the server SHALL respond with HTTP `200`.
- WHEN a `GET /` request is sent, the server SHALL return JSON containing a `name` field.
- IF the server starts successfully, the system SHALL expose the endpoint without requiring any additional setup beyond the app's normal start command.
