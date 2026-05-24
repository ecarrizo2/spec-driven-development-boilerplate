# Prompt: Plan a Task

> **Usage:** Copy this prompt into a new agent conversation. Replace `<TASK_FILE>` with a reference to the pending request file (e.g., `@1-docker-infrastructure.md`). The agent produces a plan folder ready for human review.

---

## Input

**Task request to plan:** `agent-development/pending/<TASK_FILE>`

---

## Context to Read

Before planning, read and internalize:

1. **Agent specs** — all files in `agent-development/agent-specs/`
2. **The task request** — the file specified above (including YAML frontmatter)
3. **Plan templates** — `agent-development/plans/_templates/manifest.yaml`, `specification.md`, `stage.md`
4. **Status reference** — `user-development/STATUS-REFERENCE.md`
5. **Relevant source code** — files/modules implied by the request's Implementation Details

---

## Your Task

Produce a complete plan folder in `agent-development/plans/<N-task-name>/` containing:

### 1. `manifest.yaml`

- Populate all fields from the template
- Set `plan_metadata.status: pending-approval`
- Set `plan_metadata.approval.status: pending`
- Set `plan_metadata.complexity` from the request's frontmatter
- Define stages with blast radius, verification commands, and rollback plans
- Per-stage `complexity` using Fibonacci scale (1, 2, 3, 5, 8)

### 2. `specification.md`

- Fill YAML frontmatter (plan_id, title, status: draft, approval.status: pending)
- Populate all body sections from the template
- Write thorough Open Questions for anything you cannot decide autonomously
- Include the File Manifest with all files across all stages

### 3. Stage instruction files

- One file per stage following `stage.md` template
- Step-by-step instructions with file paths, code snippets, shell commands
- Explicit blast radius (read/write lists) per stage
- Verification commands and rollback plan per stage

---

## Rules

1. **Read the source code directly** — the source code is the source of truth. Read the relevant files for the modules and areas you'll be planning changes to. Use `agent-development/agent-specs/architecture-breakdown.md` for quick orientation.
2. **Check the current project state** — look at the existing directory structure, existing source files, dependency manifests, and any previously completed plans in `agent-development/done/plans/` to understand what has already been built.
3. **Follow the templates exactly** — use the files in `agent-development/plans/_templates/` as your structural guide.
4. **Be exhaustive** — another AI agent will read the stage files and implement them. It will have no context beyond the stage file, the manifest, and the `agent-development/agent-specs/` documents. Every file to create/modify, every function signature, every shell command must be spelled out.
5. **Name the plan folder** using the pattern `N-short-name` where `N` matches the task number from the request filename.
6. **Save the plan folder** in `agent-development/plans/`.
7. **Break large plans into stages** — each stage should be a focused, independently verifiable unit of work. Spec and doc updates:
   - **Multi-stage plans (2+ implementation stages):** Add spec updates and documentation updates as **separate final stages** (penultimate and last).
   - **Single-stage plans (1 implementation stage):** Include spec and doc updates as **final steps within the single stage**.
   - In either case, if no spec or doc updates are needed, state that explicitly.
8. **Populate the blast radius** in each stage file — explicitly list which files the implementing agent is allowed to read and write.
9. **Do NOT implement any code.** This prompt is only for planning.

---

## Open Questions & Decisions (IMPORTANT)

The `specification.md` template includes an **"Open Questions & Decisions"** section. You **must** populate this section thoughtfully:

- **Surface any ambiguity** — if the task request is vague about a design choice, API contract, naming convention, data format, or trade-off, write it up as a question.
- **Present options** — for each question, list the realistic options with pros/cons.
- **Give a recommendation** — state which option you'd choose and why, but mark the human decision as `PENDING`.
- **If there are genuinely no open questions**, write "None — this plan is fully self-contained." and briefly explain why.

The human will review the `specification.md` during the **approval process**. They will answer each question, then set `approval.status: approved` in `manifest.yaml`. Do NOT assume answers to open questions — leave them for the human.

---

## Output

After saving, remind the human:
> "Review `specification.md`, resolve any PENDING questions, then set `manifest.yaml` → `approval.status: approved` when ready to execute."
