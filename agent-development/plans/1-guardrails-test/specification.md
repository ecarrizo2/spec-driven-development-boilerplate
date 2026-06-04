# Specification — E2E Guardrail & Dispatch Verification

## Overview
Verify that plan dispatch creates an execution branch + draft PR in the target repo, and that guardrails fire correctly on the SDD plan PR.

## Stages

### Stage 1: Verify guardrails
- Open a plan PR with full SDD metadata
- Confirm all 5 guardrail check runs pass
- Confirm non-SDD PRs get zero guardrail noise

### Stage 2: Verify dispatch
- Approve the plan PR
- Confirm task-assigned event arrives at sdd-test-api
- Confirm execution branch and draft PR are created

## Post-Completion Checklist
- [ ] All guardrail check runs visible on plan PR
- [ ] Non-SDD PR gets zero guardrail noise
- [ ] Plan dispatch reaches target repo
- [ ] Draft PR created in target repo
plan PR trigger
