# Stage 1: Verify Guardrails

## Objective
Confirm that all 5 guardrail checks fire on SDD PRs and skip on non-SDD PRs.

## Instructions
1. Open a plan PR with Epic ID and Task ID in the body
2. Verify Branch Naming check passes
3. Verify Cross-References check finds the Target repo PR link
4. Verify Blast Radius check passes
5. Verify Title Convention check passes
6. Verify Quality Checklist check runs

## Verification
```bash
gh pr checks <pr-number> --repo ecarrizo2/spec-driven-development-boilerplate
```

## Commit Plan
| Commit | Files | Purpose |
|--------|-------|---------|
| chore(test): verify guardrails | plan files | Test guardrail activation |
