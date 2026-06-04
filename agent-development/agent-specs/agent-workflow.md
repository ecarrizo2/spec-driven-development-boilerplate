# Agent Workflow — Hub Level

> **These workflow rules apply to ALL agent operations in this hub.**

## Two Modes of Operation

### Coordination Mode (Hub Root)

**When:** Planning epics, dispatching tasks, updating status, reviewing delivery.

**What you do:**
- Read/write files in `epics/`, `config/`, `fallback-sdd/`
- Run hub `bin/dev` commands (repo:list, dispatch, status, etc.)
- Generate task-graphs, delivery manifests, architecture diagrams
- Do NOT modify code inside `repos/<name>/` source files

### Execution Mode (Inside a Repo)

**When:** Implementing a task — writing code, running tests, creating PRs.

**What you do:**
- Work inside `repos/<name>/` (or reference `fallback-sdd/<name>/`)
- Read the spec cascade for context
- Follow the plan's blast radius constraints
- Use the repo's own `bin/dev` for build/test/lint
- After completion: update BOTH local plan AND hub task-graph (Sync Rule)

## The Sync Rule

After completing execution of a task, before ending your session:

1. **Update plan status locally:**
   - In `repos/<repo>/sdd/agent-development/plans/<plan>/manifest.yaml`
   - OR in `fallback-sdd/<repo>/agent-development/plans/<plan>/manifest.yaml`
   - Set status to `done`, move plan to `done/` directory

2. **Update hub task-graph:**
   - Edit `epics/active/<epic>/task-graph.md`
   - Set the task's `status: done` in the frontmatter

3. **Update hub delivery manifest:**
   - Edit `epics/active/<epic>/delivery.yaml`
   - Add PR URL, branch name, update node status

## Spec Resolution (What to Read)

Before starting any task execution, gather context:

| Priority | What | Where |
|----------|------|-------|
| 1 | Task plan | Plan's `manifest.yaml` + stage files |
| 2 | Repo specs | `repos/<repo>/sdd/agent-specs/` OR `fallback-sdd/<repo>/agent-specs/` |
| 3 | Hub docs | `documentation/<repo>/` + `contracts/<repo>/` + `architectural-schemas/` |
| 4 | Common specs | `common-specs/git-workflow.md`, `pr-conventions.md`, `sdd-process.md` |

Use `bin/dev resolve-spec <type> <repo>` to find the correct file.

## Blast Radius Rules

- Each plan stage declares exactly which files may be read/written
- Files not listed are OFF LIMITS
- If you need to touch an unlisted file, STOP and surface it as an open question
- Blast radius applies per-repo — you cannot touch files in other repos from one task

## Commit Conventions

- One commit per plan stage
- Conventional Commits format: `<type>(<scope>): <description>`
- Ticket ID is auto-extracted from branch name by the commit-msg hook
- Co-author trailer added automatically (configured in `config/teams.yaml`)

## Error Handling

- If a command fails, report the error and stop — don't retry blindly
- If a spec is missing, use `bin/dev resolve-spec` to find the fallback
- If blast radius is too restrictive, surface it as an open question in the specification
- If a cross-repo dependency isn't met, mark the task as `blocked` in the task-graph

## Quick Fix Track

For trivial hub-level changes (updating a status, fixing a typo in docs):
- No plan needed
- Make the change, commit, done
- Log in `agent-development/done/quick-fixes/` if notable
