---
epic_id: 1
last_updated: 2026-06-04
total_tasks: 2
tasks:
  - id: 1
    title: "Test guardrail activation"
    repo: example-api
    target_branch: null
    request_file: "requests/1-guardrails.md"
    jira_ticket: null
    gh_issue: 8
    depends_on: []
    blocks: [2]
    status: refined
  - id: 2
    title: "Test dispatch chain"
    repo: example-api
    target_branch: null
    request_file: "requests/2-dispatch.md"
    jira_ticket: null
    gh_issue: 9
    depends_on: [1]
    blocks: []
    status: draft
---
