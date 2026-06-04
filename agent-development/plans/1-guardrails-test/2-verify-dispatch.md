# Stage 2: Verify Dispatch

## Objective
Confirm that plan approval dispatches the task to the target repo and creates a draft PR.

## Instructions
1. Mark the plan PR as ready for review
2. Approve the plan PR
3. Check that the plan-execution-trigger workflow runs
4. Verify the task-assigned event is dispatched to sdd-test-api
5. Verify sdd-test-api receives the event and creates an execution branch
6. Verify a draft PR is opened in sdd-test-api with cross-reference metadata

## Verification
```bash
# Check target repo for created branch
gh api repos/ecarrizo2/sdd-test-api/branches

# Check for open PRs
gh pr list --repo ecarrizo2/sdd-test-api
```

## Commit Plan
| Commit | Files | Purpose |
|--------|-------|---------|
| chore(test): verify dispatch | none | Verify dispatch chain |
