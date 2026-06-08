---
id: MVP-001
title: "Hello World Cross-Repo Feature"
status: open
created_at: 2026-06-08T16:24:00Z
---

# MVP Epic: First Cross-Repo Feature

**Epic ID:** MVP-001  
**Status:** Open  
**Created:** 2026-06-08  

## Objective

Deliver a complete end-to-end SDD workflow: create an epic → approve → dispatch → execute in child repos → merge PRs.

## Scope

- **Frontend:** Add a simple "Hello World" component
- **API:** Add a simple `/hello` endpoint
- Cross-repo coordination through hub automation

## Definition of Done

- ✅ Epic approved by hub
- ✅ Task graph created with dependencies
- ✅ PRs created in both child repos
- ✅ PRs approved and merged
- ✅ Deployment verified

## Tasks

1. **API Task:** Implement `/hello` endpoint
   - Target repo: `sdd-test-api`
   - Depends on: none
   - Acceptance criteria:
     - GET /hello returns `{ "message": "Hello from API" }`
     - Code review passed
     - Tests pass

2. **Frontend Task:** Add Hello component  
   - Target repo: `sdd-test-frontend`
   - Depends on: Task 1 (API ready)
   - Acceptance criteria:
     - Component calls `/hello` endpoint
     - Displays response
     - Code review passed
     - Tests pass

---

*This is a minimal MVP to validate the end-to-end workflow.*
