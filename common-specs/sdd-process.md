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
| Request | Human (+ optional agent assist) | Task request in `pending/` |
| Plan | Agent | Plan folder in `plans/` (manifest + spec + stages) |
| Approve | Human | Plan status → `approved` |
| Execute | Agent | Code changes committed, plan → `done/` |
| Done | Auto | Audit trail preserved |

## The Quick Fix Track

For trivial changes (1–3 files, mechanically obvious, zero ambiguity):
- Skip the full pipeline
- Execute directly and log in `done/quick-fixes/`
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
- Plans are created in the target repo's `sdd/plans/` (or `fallback-sdd/<repo>/plans/`)
- After execution, the agent updates BOTH the local plan AND the hub's task-graph
- The hub's `delivery.yaml` tracks all PRs across all repos
