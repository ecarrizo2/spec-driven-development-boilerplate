---
epic_id: MVP-001
epic_title: "First Cross-Repo Feature"
total_tasks: 2
dependencies_enabled: true
---

# Task Graph

## Tasks

```yaml
tasks:
  - id: 1
    title: "API: Implement /hello endpoint"
    status: draft
    target_repo: sdd-test-api
    depends_on: []
    blocks: [2]
    pr_link: null
    jira_link: null

  - id: 2
    title: "Frontend: Add Hello component"
    status: draft
    target_repo: sdd-test-frontend
    depends_on: [1]
    blocks: []
    pr_link: null
    jira_link: null
```

## Dependency Graph

```
Task 1 (API) ──→ Task 2 (Frontend)
```

## Execution Order

1. **Task 1** — API endpoint (no dependencies, safe to start)
2. **Task 2** — Frontend component (waits for Task 1 to complete)

---

*Status: Ready for epic approval*
