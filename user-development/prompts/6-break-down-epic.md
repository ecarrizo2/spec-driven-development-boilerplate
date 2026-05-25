# Prompt: Break Down an Epic into Tasks

> **Usage:** Copy this prompt into a new agent conversation. Provide the path to the approved epic folder. The agent will produce a task graph, delivery manifest, and skeleton request files.

---

## Input

**Epic to break down:** `epics/active/<N-epic-name>/`

---

## Context to Read

Before producing the breakdown, read:

1. **The epic** — `epics/active/<N-epic-name>/epic.md`
2. **Agent specs** — all files in `agent-development/agent-specs/`
3. **Team config** — `config/teams.yaml` (for Jira settings, branching conventions)
4. **Architecture docs** — relevant files from `agent-development/agent-specs/architecture-breakdown.md`
5. **Relevant source code** — files/modules identified in the epic's Technical Constraints
6. **Templates** — `epics/_templates/task-graph.md`, `epics/_templates/delivery.yaml`, `agent-development/pending/_TEMPLATE-request.md`
7. **Status reference** — `user-development/STATUS-REFERENCE.md`

---

## Your Task

Decompose the epic into a task DAG. Each task becomes a request file — at this stage you produce **shells** (title, 1-paragraph goal, dependencies, complexity estimate). Full refinement happens later via Prompt 7.

---

## Rules

1. **Each task = one coherent unit of work** — one branch, one PR, independently mergeable once dependencies are met.
2. **Minimize dependencies** — prefer parallel over serial. Only add edges when Task B literally cannot be implemented without Task A's output.
3. **Order by risk** — foundational/infra tasks first, UI tasks after.
4. **Separate concerns** — data layer separate from UI, config separate from logic, migration separate from creation.
5. **Spec & doc updates are NOT separate tasks** — they're inline within each task's plan.
6. **Each task completable in one agent session** — if >500 LOC or >5 files, split further.
7. **Estimate complexity** — use Fibonacci (1, 2, 3, 5, 8, 13) per task.
8. **Name tasks with clear verbs** — "Register experiment", "Create data atom", "Migrate component X"

---

## Output

### 1. `task-graph.md`

Write to `epics/active/<N-epic-name>/task-graph.md` following the template. Include:
- YAML frontmatter with all tasks (status: `draft`, complexity estimated)
- Mermaid.js dependency diagram (NOT ASCII art)
- Parallelization notes and critical path
- Activation checklist

### 2. `delivery.yaml`

Write to `epics/active/<N-epic-name>/delivery.yaml` following the template. Include:
- One PR node per task
- `depends_on` edges matching the task-graph
- `merge_order` groups derived from the dependency DAG
- `branching_strategy` recommendation with rationale

### 3. Request shell files

For each task, create a file in `epics/active/<N-epic-name>/requests/` named `N-short-description.md`:

```markdown
---
id: N
title: "<Title>"
status: draft
complexity: <fibonacci>
jira_ticket: null
epic: "../../epic.md"
depends_on: []  # or [1, 2] etc.
created: <today>
last_updated: <today>
api_checkpoint: false  # true if this task adds/changes API endpoints
---

# Task N: <Title>

## Goal

<One paragraph: what this accomplishes and why it's a separate unit.>

## Context

<Current state, what changes, how it fits the epic.>

## Dependencies

- Depends on: <task numbers or "none">
- Blocks: <task numbers that depend on this>

## Scope

- In scope: ...
- Out of scope: ...

---

> ⚠️ **This is a request shell.** It will be refined into a full request using Prompt 7 before activation.
```

### 4. Jira Ticket Creation (if MCP available)

After creating all files, ask the human: "Should I create Jira tickets for these tasks now?"

If yes:
- Read `config/teams.yaml` for project settings
- Create one ticket per task using the configured issue type and mandatory fields
- Set Epic Link to the parent epic's Jira ticket
- Set dependency links (Blocks / Is Blocked By) matching the task-graph edges
- Record ticket IDs back into `task-graph.md` frontmatter (`jira_ticket` field per task)
- Record ticket IDs into each request shell's frontmatter

If no: leave `jira_ticket: null` fields for manual creation later.

### 5. Summary

Provide:
- Total tasks and complexity distribution
- Critical path (longest dependency chain)
- Which tasks can be parallelized
- Recommended activation order

---

## Git-Native Mode Adaptations

> If you are running as a GitHub Copilot Cloud Agent (in the hub repo), use these adaptations instead of the defaults above.

### Process Changes

- **Create a branch** `epic/N-short-name` and open a PR with all output files
- PR title: `epic(N-name): <epic title>`
- Apply label: `sdd-epic`
- Do NOT wait for confirmation — create the PR directly

### Format Requirements for Automation

The `task-graph.md` frontmatter must be parseable by `epic-dispatch.yml`:

```yaml
---
tasks:
  - id: 1
    title: "Task title"
    repo: "repo-key-from-repos-yaml"
    request_file: "1-task-name.md"
    jira_ticket: null
    depends_on: []
    status: refined  # or 'draft' if incomplete
    complexity: 3
---
```

The `delivery.yaml` must include enough metadata for automated sync:

```yaml
nodes:
  - id: "pr-1"
    task_id: 1
    repo: "repo-key"
    branch: null  # filled by agent during execution
    status: planned
    pr_url: null
    pr_number: null
    depends_on: []
```

### What Stays the Same

- Epic decomposition rules (parallel over serial, one branch per task, etc.)
- Complexity estimation (Fibonacci)
- Request shell format
- Task naming conventions
