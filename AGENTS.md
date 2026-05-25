# Multirepo Hub — Rules for AI Coding Agents

> **This is a multirepo coordination hub.** It manages cross-repo epics
> for a specific domain/project. It does NOT contain application code itself.
>
> **Replace this intro** with your domain name after scaffolding
> (e.g., "Manages cross-repo epics for the Marketplace platform").

---

## How This Hub Works

This repo coordinates planning and execution across multiple service repositories.
Each managed repo is a git submodule under `repos/`.

| Directory | Purpose |
|-----------|---------|
| `config/` | Registry (`repos.yaml`) and team settings (`teams.yaml`) |
| `epics/` | Cross-repo epic planning (epic.md, task-graph.md, delivery.yaml) |
| `repos/` | Git submodules — one per managed repo (agent-managed only) |
| `fallback-sdd/` | SDD structures for repos that lack their own `sdd/` |
| `common-specs/` | Universal conventions (git workflow, PR rules, SDD process) |
| `documentation/` | Per-repo architecture docs (fallback when repo lacks its own) |
| `contracts/` | Cross-service interface specs (API schemas, event definitions) |
| `architectural-schemas/` | System-level topology diagrams |
| `bin/` | Hub CLI commands (coordination, not build/test) |

---

## Your Two Modes of Operation

| Mode | When | What you do |
|------|------|-------------|
| **Coordination** | Planning epics, dispatching tasks, updating status | Work at hub root. Read/write `epics/`, `config/`, delivery manifests. |
| **Execution** | Implementing a task in a specific repo | Work inside `repos/<name>/`. Read that repo's `sdd/` (or `fallback-sdd/<name>/`). Make code changes. |

---

## Context Resolution (What to Read)

When executing a task in `<repo>`, read specs in this priority order:

| Priority | Source | Path |
|----------|--------|------|
| 1 | Task plan | The plan's `manifest.yaml` + stage files (blast radius, instructions) |
| 2 | Repo-level specs | `repos/<repo>/sdd/agent-development/agent-specs/` OR `fallback-sdd/<repo>/agent-development/agent-specs/` |
| 3 | Hub documentation | `documentation/<repo>/` + `contracts/<repo>/` + `architectural-schemas/` |
| 4 | Common specs | `common-specs/git-workflow.md`, `common-specs/pr-conventions.md`, `common-specs/sdd-process.md` |

**Rule:** If a spec exists at the repo level, it takes precedence over the hub's common/fallback version.

---

## The Sync Rule

After completing execution of a task, before ending your session:

1. **Update plan status locally** — in the target repo's `sdd/` (or `fallback-sdd/<repo>/`)
2. **Update hub task-graph** — set the task's status to `done` in `epics/active/<epic>/task-graph.md`
3. **Update hub delivery manifest** — add PR URL and branch name to `epics/active/<epic>/delivery.yaml`

This keeps both the local and coordination-level state in sync.

---

## Commands

### Hub-Level (`bin/dev`)

Use for coordination work (planning, dispatching, status):

| Command | Purpose |
|---------|---------|
| `bin/dev help` | Show all available commands |
| `bin/dev repo:list` | Show all repos with status |
| `bin/dev repo:sync [name]` | Update submodule(s) to latest main |
| `bin/dev repo:add <name> <url>` | Register new repo |
| `bin/dev repo:enter <name>` | Print context for a repo |
| `bin/dev repo:migrate <name>` | Move fallback-sdd into child repo |
| `bin/dev dispatch <epic-id> <task-id>` | Dispatch task to target repo |
| `bin/dev status [epic-id]` | Cross-repo epic status |
| `bin/dev wf:next` | Next actionable task |
| `bin/dev wf:validate` | Validate YAML manifests |
| `bin/dev resolve-spec <type> <repo>` | Find spec via cascade |
| `bin/dev note "msg"` | Record a finding |

### Repo-Level (inside `repos/<name>/`)

Use for execution work (building, testing, linting):

- If repo has its own `sdd/`: use `repos/<name>/sdd/bin/dev`
- If repo uses fallback: check `fallback-sdd/<name>/config/commands.yaml` for the commands

Common repo-level commands: `build`, `test`, `lint`, `verify`, `branch`, `pr:draft`

---

## Rules

1. **Never run raw `git submodule` commands.** Use `bin/dev repo:*` instead.
2. **Never edit `repos.yaml` manually during task execution.** Use `bin/dev repo:add/remove`.
3. **One epic per developer at a time.** Check `bin/dev status` for active work.
4. **Blast radius constraints apply per-repo.** Only touch files declared in the plan.
5. **Always sync after completing a task.** Follow the Sync Rule above.
6. **Source code is the source of truth.** If code contradicts a spec, code wins.
7. **No code without an approved plan.** Use the Quick Fix track only for trivial (1-3 file) changes.

---

## Fallback Resolution Pattern

For ANY SDD-related resource (specs, plans, commands):

```
Does repos/<name>/sdd/ exist?
├── YES → Use it (repo is self-sufficient)
└── NO  → Use fallback-sdd/<name>/ (hub provides structure)
```

This pattern applies to: agent-specs, pending requests, plans, config/commands.yaml, and all workflow artifacts.

---

## Git-Native SDD Mode

> This section applies when using the **git-flow** branch workflow with GitHub Copilot Cloud Agent.
> It describes the PR-based, CI-driven alternative to the local filesystem-based workflow.

### Overview

In Git-Native mode:
- **PRs are the universal interface** — if it's not in a PR, it doesn't exist
- **GitHub Actions is the orchestrator** — all automated transitions are GH Actions
- **Copilot Cloud Agent is the execution engine** — all agent work goes through it
- **Issues are the dispatch mechanism** — assigning an issue to `@copilot` starts work

### Plan Phase (Git-Native)

- You receive work via GitHub Issues (assigned to you with label `sdd-plan`)
- Create a branch `plan/<JIRA-ID>-<description>` and open a PR with plan files only
- The issue body contains all context you need (epic, request, specs)
- Write plan files to `sdd/plans/<task-name>/` (in target repos)
- Do NOT write code during the plan phase
- Mark PR ready for review when plan is complete

### Execution Phase (Git-Native)

- You receive work via GitHub Issues (assigned to you with label `sdd-execute`)
- The plan is already approved and on `main` — read it from there
- Create a branch `feat/<JIRA-ID>-<description>` and implement the plan
- Push commits incrementally, the draft PR updates automatically
- Run verification after each stage (lint, typecheck, test)
- Mark ready for review only after all stages pass verification

### Commit Convention (Git-Native)

```
<type>(<scope>): <JIRA-ID> <description>

Co-authored-by: Copilot <noreply@github.com>
```

### Branch Naming (Git-Native)

| Phase | Pattern | Example |
|-------|---------|----------|
| Epic (hub) | `epic/<N>-<short-name>` | `epic/3-user-awards` |
| Plan (target) | `plan/<JIRA-ID>-<short-name>` | `plan/PROJ-123-add-v2-endpoint` |
| Code (target) | `feat/<JIRA-ID>-<short-name>` | `feat/PROJ-123-add-v2-endpoint` |
| Hotfix | `fix/<JIRA-ID>-<short-name>` | `fix/PROJ-456-null-check` |

### Labels (Git-Native)

| Label | Applied To | Purpose |
|-------|-----------|----------|
| `sdd-plan` | Plan issues and PRs | Identifies planning phase work |
| `sdd-execute` | Execution issues and PRs | Identifies implementation phase work |
| `epic-N` | All issues/PRs for epic N | Groups work by epic |
| `alignment-checked` | Code PRs after check runs | Prevents re-running check |

### Hub vs Target Repo Actions

| Action | Location | Trigger |
|--------|----------|----------|
| `epic-dispatch.yml` | Hub | Epic PR merged → creates issues in target repos |
| `sync-status.yml` | Hub | Periodic — syncs delivery manifest statuses |
| `copilot-setup-steps.yml` | Target repos | Configures Copilot's environment |
| `plan-merged.yml` | Target repos | Plan PR merged → creates execution issue |
| `alignment-check.yml` | Target repos | Code PR ready for review → validates alignment |
| `sync-hub.yml` | Target repos | Code PR merged → updates hub delivery manifest |

### Coexistence with Local Mode

Both modes use the same planning artifacts and conventions — only the execution mechanism differs:
- **Local mode** (default): IDE-based agents, local filesystem state, `bin/dev` commands
- **Git-native mode**: Cloud agents, PR-based state, GitHub Actions orchestration

See `target-repo-template/` for the files to copy into target repos when adopting git-native mode.
