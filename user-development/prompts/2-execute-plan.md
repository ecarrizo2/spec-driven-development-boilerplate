# Prompt: Execute an Approved Plan

> **Usage:** Copy this prompt into a new agent conversation. Replace `<PLAN_FOLDER>` with a reference to the approved plan folder in `plans/` (e.g., `@1-docker-infrastructure`).

---

## Input

**Plan folder:** `agent-development/plans/<PLAN_FOLDER>/`

---

## Before Starting

1. **Read all spec documents** in `agent-development/agent-specs/`:
   - `agent-development/agent-specs/agent-instructions.md`
   - `agent-development/agent-specs/agent-workflow.md`
   - `agent-development/agent-specs/application-overview.md`
   - `agent-development/agent-specs/architecture-breakdown.md`
   - `agent-development/agent-specs/git-workflow.md`

2. **Read the plan:**
   - `manifest.yaml` — authoritative record of task state, stages, and approval.
   - `specification.md` — human-readable overview with context, open questions, and file manifest.

3. **Check `manifest.yaml` → `plan_metadata.approval.status`** — it must equal `approved`. If not, **STOP** and report that the plan has not been approved yet.

4. **Check the "Open Questions & Decisions" section** in `specification.md`. If any question still says `PENDING`, **STOP** and report which questions are unresolved. Do not execute a plan with pending decisions. Treat resolved human decisions as **binding requirements**.

5. **Check `manifest.yaml` for `current_stage`** — if execution was previously interrupted, resume from the current stage rather than starting over. Stages already marked `done` should not be re-executed.

---

## Execution

Follow the workflow defined in `agent-development/agent-specs/agent-workflow.md`. That file is the authoritative reference for:

- How to execute stages in order
- Blast radius enforcement (which files you may read and write)
- When and how to update `manifest.yaml`
- When and how to commit (one commit per stage, conventional commit format)
- How spec/doc updates are handled (inline for single-stage plans, separate stages for multi-stage plans)
- Post-completion file moves and archive commit

Execute stages **in order**, one at a time. For each stage:
1. Read its instruction file
2. Follow the instructions exactly
3. Run verification commands
4. Update `manifest.yaml` (stage status → `done`, increment `current_stage`)
5. Commit with conventional commit format

Do not add features, refactor code, or make architectural decisions that aren't in the stage instructions.

If a verification check fails, fix the issue and retry (max 2 attempts per check). If it still fails, report the failure clearly, set the stage's status to `failed` in `manifest.yaml`, follow the stage's rollback plan, and continue to the next stage only if it doesn't depend on the failed one.

---

## After All Stages Complete

1. Update `manifest.yaml`: set `plan_metadata.status: done`
2. Archive: move plan folder → `agent-development/done/plans/`
3. Archive: move request → `agent-development/done/requests/`
4. Final commit: `chore: archive completed plan and request`

---

## Final Report

After all stages are complete and archive moves are done, provide a short summary:

- ✅ Stages completed (list each with its name and status)
- 🔑 Open questions — list each resolved question and the human decision that was applied
- ⚠️ Warnings or issues encountered (even if resolved)
- 📁 Files created or modified (aggregate across all stages)
- 🔀 Files moved (plan folder and request)
- 🔖 Commits made (list each commit message)
