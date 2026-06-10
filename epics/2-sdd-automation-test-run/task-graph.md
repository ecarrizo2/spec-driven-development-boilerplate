---
epic_id: 2
epic_title: "Cross-repo automation test run"
total_tasks: 2
last_updated: 2026-06-10
critical_path: [1, 2]
tasks:
  - id: 1
    title: "Create API greeting endpoint"
    repo: "sdd-test-api"
    target_branch: null
    request_file: "requests/1-create-api-greeting-endpoint.md"
    jira_ticket: null
    gh_issue: null
    depends_on: []
    blocks: [2]
    status: draft
    complexity: 3
    assigned_to: null
  - id: 2
    title: "Create frontend greeting page"
    repo: "sdd-test-frontend"
    target_branch: null
    request_file: "requests/2-create-frontend-greeting-page.md"
    jira_ticket: null
    gh_issue: null
    depends_on: [1]
    blocks: []
    status: draft
    complexity: 3
    assigned_to: null
negotiations: []
---

# Task Graph: Cross-repo automation test run

```mermaid
graph TD
  T1[1: Create API greeting endpoint<br>sdd-test-api]
  T2[2: Create frontend greeting page<br>sdd-test-frontend]
  T1 --> T2
```
