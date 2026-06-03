# SDD Process Rules

> **Scope:** These rules are universal across all repos in this hub. They define how the Spec-Driven Development workflow operates.

## Core Principles

1. **No code without an approved plan.** Every non-trivial change goes through Request → Plan → Approve → Execute.
2. **Human decides what, agent decides how.** Humans write requests (outcomes); agents produce implementation plans (approach).
3. **Source code is the source of truth.** If code contradicts a spec, code wins — update the spec.
4. **Blast radius is law.** Each plan stage declares exactly which files may be read/written. Out-of-scope changes are forbidden.

## The Pipeline

```
Request → Plan → Approve → Execute → Done
```

| Stage | Actor | Output |
|-------|-------|--------|
| Request | Human (+ optional agent assist) | Task request in `requests/` |
| Plan | Agent | Plan folder in `plans/` (manifest + spec + stages) |
| Approve | Human | Plan status → `approved` |
| Execute | Agent | Code changes committed, plan `manifest.yaml` → `status: done` |
| Done | Auto | Audit trail preserved in `plans/` |

## The Quick Fix Track

For trivial changes (1–3 files, mechanically obvious, zero ambiguity):
- Skip the full pipeline
- Execute directly and log in `quick-fixes/`
- If any doubt arises, escalate to the full pipeline

## Open Questions Mechanism

Agents MUST surface ambiguity rather than guess:
- Write `PENDING` markers in the specification when encountering unclear requirements
- Include options with pros/cons and a recommendation
- Human resolves all `PENDING` markers before approval
- Executing agents refuse to proceed if any `PENDING` markers remain

## Blast Radius Constraints

Each plan stage declares:
- **Read access:** Files the agent may read for context
- **Write access:** Files the agent may create or modify
- Any file not listed is OFF LIMITS

## Plan Structure

Plans are folders containing:
- `manifest.yaml` — Machine-readable state (status, stages, metadata)
- `specification.md` — Human-readable overview and open questions
- `1-stage-name.md` ... `N-stage-name.md` — Per-stage execution instructions

## Status Transitions

```
Request:  draft → refined → activated → planned → done
Plan:     draft → pending-approval → approved → in-progress → done
```

## Multirepo Extensions

In a multirepo hub:
- Requests carry a `target_repo` field identifying which repo they execute in

## Hub Branch Model

The hub uses two distinct branch types with separate lifecycles:

### Epic branches — `epic/<ticket-id>_<description>`

Short-lived. Define the epic (epic.md, task-graph.md, delivery.yaml) and all pending requests. Merged to `main` once all requests are refined and the task graph is approved — **before any execution begins**. After merge the epic is considered active.

### Plan branches — `plan/<ticket-id>_<description>`

One per task. Created when the agent starts planning. Contains:
- Plan files in `fallback-sdd/<repo>/agent-development/plans/<task>/` (`manifest.yaml` → `status: done` after execution)
- Status updates to `epics/<epic>/task-graph.md` and `delivery.yaml`
- Architecture doc updates in `documentation/<repo>/` (for fallback-SDD repos)

**Lifecycle:**
```
draft PR (plan files visible for review)
  → human approves plan (sets manifest.yaml approval.status: approved)
  → agent creates target repo branch + PR
  → agent executes implementation
  → agent syncs: plan → done, delivery.yaml updated
  → hub PR marked ready for review
  → merged to main (after target repo PR is also merged)
```

### Linking hub plan PR ↔ target repo PR

Both PRs reference each other in their descriptions:
- Hub plan PR: `**Target repo PR:** <org>/<repo>#<number>`
- Target repo PR: `**Hub plan PR:** <org>/<hub-repo-name>#<number>`

### For repos with own SDD (`has_own_sdd: true`)

There is no hub plan branch. Plan files, code changes, and doc updates all live together on the target repo branch. One PR, one review, one merge.

## Architecture Documentation Rule

### The Problem

`application-overview.md` (in `agent-specs/`) is a **mandatory read** for every agent session. If implementation details accumulate there, it becomes bloated and wastes context window on every task — even unrelated ones.

### The Rule

1. **`application-overview.md` stays lean.** It contains only:
   - Application purpose (1 paragraph)
   - Core workflow summaries (2–3 sentences each)
   - Pointers to detailed docs: `**Architecture doc:** \`XX-name.md\``
   - Key integration points (brief list)
   - Out of scope (brief list)

2. **Detailed docs live in `architecture-documentation/`** (repo-level) or `documentation/<repo>/` (hub fallback). These are the expandable, in-depth references.

3. **When a plan changes architecture**, the executing agent MUST:
   - Update the relevant detailed doc in `architecture-documentation/` (or create a new numbered doc if the area is new)
   - Update the pointer in `application-overview.md` only if a new doc was created or a workflow summary needs a one-line adjustment
   - Never add multi-paragraph implementation details to the overview

4. **During plan creation** (Prompt 1), the planning agent MUST:
   - Assess whether the plan touches architecture
   - If yes: include a "Documentation update" step in the final stage's commit table
   - List which `architecture-documentation/` files will be created or modified

### Resolution Path

```
Does the repo have its own architecture-documentation/ ?
├── YES → Update docs there (committed with the feature PR)
└── NO  → Update docs in hub's documentation/<repo>/ (committed in hub)
```

This ensures the overview remains a quick routing table — not a growing encyclopedia.
