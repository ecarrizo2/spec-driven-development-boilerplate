---
epic_id: 2
epic_title: "API and React Code Generation MVP"
total_tasks: 2
last_updated: 2026-06-09
critical_path: [1, 2]
tasks:
  - id: 1
    title: "Create a minimal Express hello-world API"
    repo: "sdd-test-api"
    target_branch: null
    request_file: "1-api-express-hello.md"
    jira_ticket: null
    gh_issue: null
    depends_on: []
    blocks: [2]
    status: draft
    complexity: 2
    assigned_to: null
  - id: 2
    title: "Create a minimal React dashboard that greets the API name"
    repo: "sdd-test-frontend"
    target_branch: null
    request_file: "2-react-dashboard-greeting.md"
    jira_ticket: null
    gh_issue: null
    depends_on: [1]
    blocks: []
    status: draft
    complexity: 2
    assigned_to: null
negotiations: []
---

# Task Graph: API and React Code Generation MVP

> **Epic:** `../epic.md`
> **Total tasks:** 2
> **Last updated:** 2026-06-09

## Dependency Diagram

```mermaid
graph TD
    T1[1: Create a minimal Express hello-world API<br>sdd-test-api]:::accent0
    T2[2: Create a minimal React dashboard that greets the API name<br>sdd-test-frontend]:::accent1

    T1 --> T2
```

## Parallelization Notes

- Task 1 must land first so the API contract is available.
- Task 2 is blocked on Task 1 and verifies cross-repo dependency handling.
- Recommended activation order: 1 → 2.

