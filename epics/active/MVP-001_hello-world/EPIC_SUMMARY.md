# MVP-001: Hello World Cross-Repo Feature

## Epic Status: Ready for Approval ✅

This epic demonstrates a complete end-to-end SDD workflow:
1. Epic approval in hub
2. Task dispatch to child repos
3. PR creation in child repos
4. Implementation and merge
5. Automatic status sync

## Tasks

### Task 1: API Endpoint
- **Repo:** sdd-test-api
- **Deliverable:** GET /hello endpoint
- **Response:** `{ "message": "Hello from API" }`
- **Status:** draft → ready for dispatch
- **Dependencies:** None

### Task 2: Frontend Component  
- **Repo:** sdd-test-frontend
- **Deliverable:** HelloWorld React component
- **Behavior:** Fetch from /hello and display message
- **Status:** draft → ready for dispatch
- **Dependencies:** Task 1 (must be merged first)

## Safety Gates Active

✅ PENDING Marker Blocking - Prevents incomplete specs from dispatch  
✅ Dependency Blocking - Task 2 won't dispatch until Task 1 merged  
✅ Auto Status Updates - No manual edits required  
✅ Real-time Dashboard - `bin/dev dashboard MVP-001` tracks progress  

## Files

- `epic.md` - Full epic definition
- `task-graph.md` - Task dependencies and status tracking
- `delivery.yaml` - PR URLs and deployment status
- `requests/` - Task specifications

## Execution Flow

```
Epic Approved
    ↓
Dispatch Task 1 → PR created in sdd-test-api
    ↓
Implement & Merge Task 1
    ↓
Hub receives merge event → Task 1 marked done
    ↓
Dispatch Task 2 → PR created in sdd-test-frontend
    ↓
Implement & Merge Task 2
    ↓
Hub receives merge event → Epic complete ✅
```

## Next Steps

1. Review this epic
2. Approve the PR
3. Run: `bin/dev dispatch MVP-001 1` (dispatch Task 1)
4. Run: `bin/dev dispatch MVP-001 2` (dispatch Task 2)
5. Watch PRs auto-create in child repos
6. Implement features
7. Merge PRs
8. Check: `bin/dev dashboard MVP-001`

---

*Ready to execute end-to-end SDD workflow!*
