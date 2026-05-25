# Prompt 8: Dispatch Tasks to Target Repos

> **When to use:** After an epic's task-graph is finalized, tickets are created, and you want to activate one or more tasks for execution.
>
> **Actor:** Human (with agent assistance)
>
> **Prerequisite:** Epic exists in `epics/active/`, task-graph is confirmed, request files are refined (status: `refined`).

---

## Instructions

I need to dispatch tasks from epic `<EPIC_ID>` to their target repos for execution.

### Context

- Epic location: `epics/active/<EPIC_ID>-<name>/`
- Read the task-graph to understand which tasks are ready (dependencies satisfied)
- Read `config/repos.yaml` to understand the target repos

### What to Do

For each task I specify (or for all tasks whose dependencies are satisfied):

1. **Verify the request is refined** — check `status: refined` in the request's frontmatter
2. **Run dispatch:** `bin/dev dispatch <epic-id> <task-id>` for each task
3. **Confirm the copy** — verify the request file now exists in the target location:
   - If repo has `sdd/`: `repos/<repo>/sdd/agent-development/pending/<N>-<name>.md`
   - If repo uses fallback: `fallback-sdd/<repo>/agent-development/pending/<N>-<name>.md`
4. **Update the task-graph** — set each dispatched task's status to `activated`
5. **Create the delivery.yaml** (if it doesn't exist yet) from the template

### Tasks to Dispatch

_Specify which tasks, or say "all ready tasks":_

- Task `<ID>` → `<repo-name>`
- ...

### After Dispatch

Report:
- Which tasks were dispatched successfully
- Where each request file landed
- Which tasks are now ready for planning (next step: Prompt 1 in the target repo context)
- Any tasks that couldn't be dispatched (missing deps, not refined, etc.)
