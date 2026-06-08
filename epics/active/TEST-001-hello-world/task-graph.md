# Task Graph: Hello World MVP

| Task ID | Title | Status | Repo | Depends On | GH Issue | Jira Ticket | Request File |
|---------|-------|--------|------|------------|----------|-------------|--------------|
| 1 | API Hello Endpoint | draft | sdd-test-api | - | | | task-1-api.md |
| 2 | Frontend Hello Component | draft | sdd-test-frontend | 1 | | | task-2-frontend.md |

## Task Details

### Task 1: API Hello Endpoint
- **Status**: draft
- **Target repo**: sdd-test-api
- **Dependencies**: None
- **Description**: Create GET /api/hello endpoint

### Task 2: Frontend Hello Component
- **Status**: draft
- **Target repo**: sdd-test-frontend
- **Dependencies**: Task 1 (API endpoint must be ready)
- **Description**: Create component that calls /api/hello and displays message
