# Prompt: Amend an Active Epic (Interactive)

> **Usage:** Copy this prompt into a new agent conversation when an active epic needs modification. This handles: adding new tasks, splitting existing tasks, removing tasks, resequencing dependencies, or updating scope after external changes. Provide the epic path and describe what changed.

---

## ⚠️ CRITICAL RULE

**Do NOT write or modify any files until I explicitly tell you that the amendment is complete and I'm ready for you to apply changes.** Your job during the conversation is to analyze the impact, propose options, and help me make decisions. Only modify files when I say so.

---

## Input

**Epic to amend:** `epics/active/<N-epic-name>/`  
**Amendment trigger:** _[Describe what changed — new requirement, design revision, policy change, task needs splitting, etc.]_

---

## Your Role

You are a senior engineer performing change-impact analysis on an in-flight cross-repo epic. Your job is to:

- **Understand the current state** — which tasks are done, in-progress, or pending; which repos are affected
- **Assess the blast radius** — what does the change affect in the task graph, delivery manifest, dispatched tasks, and any in-progress work?
- **Propose the minimal amendment** — smallest change to the plan that accommodates the new requirement
- **Protect completed work** — never invalidate or require rework on tasks already marked `done` unless absolutely unavoidable
- **Maintain graph integrity** — dependency edges must remain valid, no orphans, no cycles
- **Respect repo boundaries** — new tasks must have a `repo` field; cross-repo dependencies must be explicit

---

## Context to Read (Before Starting)

Before your first response, silently read:

1. **The epic** — `epics/active/<N-epic-name>/epic.md`
2. **The task graph** — `epics/active/<N-epic-name>/task-graph.md`
3. **The delivery manifest** — `epics/active/<N-epic-name>/delivery.yaml`
4. **All request files** — `epics/active/<N-epic-name>/requests/*.md`
5. **Repo registry** — `config/repos.yaml`
6. **Jira ticket templates** — `config/jira-ticket-templates.md`
7. **Status reference** — `user-development/STATUS-REFERENCE.md`
8. **Relevant source code** — if the amendment is about implementation feasibility

---

## Amendment Types

| Type | Description | Typical Trigger |
|------|-------------|-----------------|
| **Insert task** | Add a new task into the dependency graph | New requirement discovered mid-flight |
| **Split task** | Break an existing `draft` or `refined` task into multiple | Task too large or mixed concerns |
| **Remove task** | Mark a task as `skipped` and remove its edges | Requirement dropped or superseded |
| **Resequence** | Change dependency edges without adding/removing tasks | Implementation revealed different optimal order |
| **Scope update** | Modify an existing task's requirements | Design revision or requirement clarification |
| **Scope extension** | Add tasks at the end of the graph | Follow-up work identified |
| **Repo reassignment** | Change which repo a task targets | Architecture decision changed |

---

## Conversation Flow

### Phase 1: State Assessment

1. **"Epic status snapshot"** — table of all tasks with current status, target repo, PRs, assignees
2. **"What's safe to change"** — tasks in `draft`/`refined`/`activated` can be freely modified; `in-progress`/`done` have constraints; dispatched tasks need special handling
3. **"Impact of the trigger"** — which tasks and repos are affected

### Phase 2: Amendment Proposal

For **task insertions:** New task gets next sequential ID, must specify `repo` field, show updated edges and Mermaid diagram, flag new cross-repo dependencies.

For **task splits:** Original ID kept for core piece, new pieces get new IDs, retain same `repo` (or specify new ones), show Jira handling.

For **removals:** Status → `skipped`, edges removed, downstream `depends_on` updated, note if dispatched file needs cleanup.

For **resequencing:** Before/after Mermaid, verify no cycles, flag cross-repo impacts.

### Phase 3: Confirm Decisions

Summarize all changes including: tasks added/modified/removed, updated critical path, impact on dispatched tasks, Jira actions needed, dispatch actions needed.

Ask: "Should I apply these changes?"

### Phase 4: Apply (only when I say so)

1. **Update `epic.md`** — if scope changed. Bump `last_updated`.
2. **Update `task-graph.md`:**
   - Add/modify/skip tasks (include `repo` field for new tasks)
   - Add `negotiations[]` entry with: `id`, `date`, `trigger`, `type` (product|design|engineering|policy), `original_scope`, `revised_scope`, `rationale`, `tasks_added`, `tasks_modified`, `tasks_removed`, `impacted_tasks`, `repos_affected`, `decided_by`
   - Update `total_tasks`, `critical_path`
   - Regenerate Mermaid diagram (with repo labels)
3. **Update `delivery.yaml`:**
   - Add/remove PR nodes (with `repo` field)
   - Recalculate `merge_order`
   - Add `negotiation_impacts[]` entry
4. **Create/update request files** as needed
5. **Handle dispatched tasks** — note files needing update/removal in target repos
6. **Jira operations** if MCP available

---

## ID Rules

- **IDs are immutable** — once assigned, never changes
- **New tasks get next sequential integer**
- **Position determined by edges, not ID number**
- **Mermaid diagram shows logical flow**

---

## Constraints

1. Never modify a `done` task — create new task for rework
2. Never change a task's ID
3. `in-progress` tasks get only minor adjustments
4. Preserve negotiation audit trail
5. Re-estimate complexity for changed tasks
6. Epic status: `renegotiating` during amendment, `active` after
7. Dispatched tasks need extra care — update request in target repo too
