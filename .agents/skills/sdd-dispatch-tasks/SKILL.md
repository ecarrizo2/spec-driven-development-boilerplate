---
name: sdd-dispatch-tasks
description: Dispatch refined epic tasks to their target repos for execution — copies request files to the correct location, updates task statuses to 'activated', and reports which tasks are ready for planning.
---

## Identify the Epic and Tasks

Before starting, determine which epic and tasks to dispatch:

1. **If you mentioned a specific epic and tasks** — confirm the epic folder and task IDs.
2. **If you mentioned an epic only** — run `bin/dev wf:next` or read the epic's `task-graph.md` to identify which tasks have `status: refined` and satisfied dependencies.
3. **If unspecified** — run `bin/dev status` to show active epics and their pending tasks.

State which tasks you'll dispatch before proceeding.

## Instructions

### Context

- Epic location: `epics/<EPIC_ID>-<name>/`
- Read the task-graph to understand which tasks are ready (dependencies satisfied)
- Read `config/repos.yaml` to understand the target repos

### What to Do

For each task I specify (or for all tasks whose dependencies are satisfied):

1. **Verify the request is refined** — check `status: refined` in the request's frontmatter
2. **Run dispatch:** `bin/dev dispatch <epic-id> <task-id>` for each task
3. **Confirm the copy** — verify the request file now exists in the target location:
   - If repo has `sdd/`: `repos/<repo>/sdd/agent-development/requests/<N>-<name>.md`
   - If repo uses fallback: `fallback-sdd/<repo>/agent-development/requests/<N>-<name>.md`
4. **Update the task-graph** — set each dispatched task's status to `activated`
5. **Create the delivery.yaml** (if it doesn't exist yet) from the template

### After Dispatch

Report:
- Which tasks were dispatched successfully
- Where each request file landed
- Which tasks are now ready for planning (next step: Prompt 1 in the target repo context)
- Any tasks that couldn't be dispatched (missing deps, not refined, etc.)
