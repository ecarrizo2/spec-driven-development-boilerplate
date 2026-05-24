<!--- Title format: type(scope): TICKET-123 description (same as the branch's primary commit type) -->

## Description

<!--- What does this PR do? Summarize the goal and approach in 2-3 sentences. -->

## Related Issue

<!--- Jira ticket link -->

https://your-org.atlassian.net/browse/TICKET-ID

## Pull request instance

> **Friendly Reminder:** When relevant, make sure that work has been QA'd on PR instance before merging to develop

<PR_PREVIEW_URL>

## Review Guide

> 💡 **How to review this PR:**
> 1. Go to the **Commits** tab above
> 2. Review each commit individually — each one corresponds to a plan stage
> 3. Use the table below to understand what each commit does and where to focus

| Commit | Stage | Files changed | What to look for |
|---|---|---|---|
| `_______` | 1: Stage name | N files | Focus area / key decisions |
| `_______` | 2: Stage name | N files | Focus area / key decisions |
| `_______` | 3: Stage name | N files | Focus area / key decisions |

<!---
  Fill in this table with actual commit SHAs, stage names, file counts, and review focus.
  The executing agent (Prompt 2) generates this table as part of its final output.
-->

### Key Decisions

<!--- List any non-obvious architectural or implementation decisions the reviewer should know about. These come from the "Open Questions & Decisions" section of the plan's specification.md -->

- ...

## Epic & Plan Context

<!--- Link to the originating request and plan for full context -->

| Artifact | Path |
|---|---|
| Epic | `epics/active/N-name/epic.md` (or N/A if standalone) |
| Request | `agent-development/done/requests/N-name.md` |
| Plan | `agent-development/done/plans/N-name/specification.md` |

## Types of changes

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Chore (maintenance/tech debt)
- [ ] Refactor (no behavior change)

## Checklist

- [ ] `<build_command>` passes
- [ ] `<test_command>` passes (relevant test files)
- [ ] `<lint_command>` passes
- [ ] `<typecheck_command>` passes
- [ ] I have reviewed the agent's output for correctness
- [ ] I have verified the Review Guide table matches the actual commits
- [ ] All plan stages completed successfully (check `manifest.yaml`)
- [ ] Documentation updated as needed
