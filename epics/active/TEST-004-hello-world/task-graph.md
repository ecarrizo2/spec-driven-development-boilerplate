---
epic_id: TEST-004
epic_title: Hello World Workflow Validation
total_tasks: 2
last_updated: 2026-06-08
critical_path: [1, 2]

tasks:
  - id: 1
    title: "API Hello Endpoint"
    repo: "sdd-test-api"
    target_branch: null
    request_file: "task-1-api.md"
    jira_ticket: null
    gh_issue: null
    depends_on: []
    blocks: [2]
    status: draft
    complexity: null
    assigned_to: null
  - id: 2
    title: "Frontend Hello Component"
    repo: "sdd-test-frontend"
    target_branch: null
    request_file: "task-2-frontend.md"
    jira_ticket: null
    gh_issue: null
    depends_on: [1]
    blocks: []
    status: draft
    complexity: null
    assigned_to: null

negotiations: []
---

# Task Graph: Hello World Workflow Validation
