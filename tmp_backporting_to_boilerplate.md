# Backporting Marketplace Hub → SDD Boilerplate

## Context

This document summarises a backport session and hands off the remaining work (Pass 2) to a new agent session.

### What Is Being Done

The `sdd-boilerplate` repo (at `/Users/dmolinari/vimwiki/sdd-boilerplate`) is the scaffolding template used to bootstrap multirepo SDD hubs. The `marketplace-sdd-hub` (at `/Users/dmolinari/mktplace/marketplace-sdd-hub`) was bootstrapped from it and has since evolved significantly through several planned improvements. The goal is to backport all generic improvements back into the boilerplate so future hubs start from the latest methodology.

### Key methodology changes made in the hub (what you're backporting)

1. **Skills system** — `.agents/skills/<name>/SKILL.md` is now the canonical entry point for agents (Zed/Claude Code auto-match by description). `.github/prompts/` are VS Code Copilot aliases (symlinks). `user-development/prompts/` is the copy-paste fallback.
2. **EARS notation** — acceptance criteria now use EARS patterns (WHEN/WHILE/IF/WHERE/SHALL). Documented in `common-specs/writing-specs.md`.
3. **SDD failure modes** — three named failure modes: `intent drift`, `context decay`, `unverifiable output`. Shared vocabulary for retros and escalation.
4. **Epic status simplified** — old 8-state vocab (`draft → discussing → decomposed → …`) replaced with deployment-lifecycle vocab: `pending → active → paused → ready-for-deployment → deployed → done`.
5. **Hub Branch Model** — two distinct branch types: `epic/<ticket-id>_<description>` (defines the epic, short-lived) and `plan/<ticket-id>_<description>` (one per task, contains plan files + sync updates). Both PRs must cross-reference each other.
6. **No more physical file moves** — plans stay in `plans/` in-place after completion (`manifest.yaml → plan_metadata.status: done`). No `done/` archiving subdirs. `specification.md` has NO `status:` field (approval lives only in `manifest.yaml`).
7. **Flat epic structure** — `epics/active/` and `epics/done/` directories removed. All epics live in `epics/` directly. Status field is the sole lifecycle indicator.
8. **Jira ticket timing** — tickets created after refinement (Prompt 7), NOT at breakdown time (Prompt 6).
9. **Epic Ticket Template** — `config/jira-ticket-templates.md` gained a full Epic Ticket Template section alongside the task ticket template.
10. **Architecture Documentation Rule** — `application-overview.md` must stay lean (routing table only). Detailed docs go in `architecture-documentation/` (repo) or `documentation/<repo>/` (hub fallback). Every plan must assess doc impact.
11. **Context Freshness Check** (Prompt 1) — before planning, verify docs aren't stale (>90 days via `git log -1`). Check `metrics/<team-name>/cycles/` for recurring amendment patterns.
12. **Auditing & metrics** — `AUDITING-AND-METRICS.md` documents how amendments are recorded and metrics computed. `bin/dev wf:archive` auto-runs the audit.
13. **SQUAD_FLOW.md** — comprehensive squad choreography doc (RACI, per-phase input requirements, prompt chain data flow, mid-flight amendments).
14. **`agent-development/pending/` renamed** to `agent-development/requests/` everywhere.
15. **`discovered_during` field** added to request frontmatter template.
16. **`writing-specs.md` added to Priority 4 spec cascade** in AGENTS.md.
17. **PR Template** — gained an "Amendments Discovered" section with structured amendment types.
18. **Retro analysis** — new Prompt 9 (`9-retro-analysis.md`) and matching skill.
19. **decisions/ directory** — ADR structure added.

---

## Pass 1 — COMPLETED

The following was already done in the previous session:

### Structural operations (done)
- `agent-development/pending/` → `agent-development/requests/` (renamed)
- `agent-development/done/` removed (no more archiving subdirs)
- `epics/active/` and `epics/done/` removed (flat structure)
- `user-development/prompts/11-amend-epic.md` → `9-amend-epic.md`
- `quick-fixes/` log path changed from `agent-development/done/quick-fixes/` to `agent-development/quick-fixes/`

### New directories + files created (done)
- `.agents/skills/` — 11 skill subdirectories, each with a `SKILL.md` (all written, minor Marketplace refs scrubbed)
- `.github/prompts/` — 11 symlinks pointing to `.agents/skills/*/SKILL.md` + README
- `decisions/README.md` — blank ADR index with format template
- `common-specs/writing-specs.md` — EARS patterns, failure modes, SDD vs TDD/BDD table (fully generic)
- `user-development/AUDITING-AND-METRICS.md` — metrics flow, audit commands, schema guide (templated with `<team-name>` placeholders)
- `user-development/prompts/9-retro-analysis.md` — retro prompt (templated)

---

## Pass 2 — YOUR TASK

Pass 2 is **selective merge**: for each file below, read the current boilerplate version, then apply the specific changes described. Do NOT blindly copy from the hub — the hub has Marketplace-specific content in many files. Apply only the changes listed.

The boilerplate is at: `/Users/dmolinari/vimwiki/sdd-boilerplate`
The hub (source of improvements) is at: `/Users/dmolinari/mktplace/marketplace-sdd-hub`

---

### File 1: `AGENTS.md`

**Read:** `sdd-boilerplate/AGENTS.md`

**Apply these changes:**

1. In the **Context Resolution** table (Priority 4 row), add `common-specs/writing-specs.md` to the list:
   ```
   | 4 | Common specs | `common-specs/git-workflow.md`, `common-specs/pr-conventions.md`, `common-specs/sdd-process.md`, `common-specs/writing-specs.md` |
   ```

2. Replace the **Sync Rule** section (currently 3 steps) with this 4-step version:
   ```
   1. **Update plan status** — set `manifest.yaml` → `status: done` on the hub plan branch
   2. **Update hub task-graph** — set the task's status to `done` in `epics/<epic>/task-graph.md` on the hub plan branch
   3. **Update hub delivery manifest** — add the target repo's PR URL and branch name to `epics/<epic>/delivery.yaml` on the hub plan branch
   4. **Mark hub plan PR ready for review** — the plan branch PR moves from draft to ready once the target repo PR exists and the plan is complete
   ```

3. Add a new **Hub Branch Model** section after the Sync Rule section (before Commands). Copy it verbatim from `marketplace-sdd-hub/AGENTS.md` — it starts with `## Hub Branch Model` and ends before `## Commands`. It covers: epic branches, plan branches, target repo branches, and cross-PR linking rules.

4. Add an **Available Skills** section at the end (after Rules), copy verbatim from `marketplace-sdd-hub/AGENTS.md` — the section starting with `## Available Skills`. It contains a table of all 11 skills with descriptions and modes, plus the three file location lines at the bottom.

---

### File 2: `common-specs/sdd-process.md`

**Read:** `sdd-boilerplate/common-specs/sdd-process.md`

**Apply these changes:**

1. In the workflow table, update the `Request` row path from `pending/` to `requests/`:
   ```
   | Request | Human (+ optional agent assist) | Task request in `requests/` |
   ```

2. Update the `Execute` and `Done` rows to reflect no archiving:
   ```
   | Execute | Agent | Code changes committed, plan `manifest.yaml` → `status: done` |
   | Done | Auto | Audit trail preserved in `plans/` |
   ```

3. Update quick-fix log path: `done/quick-fixes/` → `quick-fixes/`

4. Update plan location description: plans are created in the hub on a dedicated `plan/` branch (not in the target repo's `sdd/plans/`).

5. Add a **Hub Branch Model** section after the existing content (before any Rules section if present). Copy it from `marketplace-sdd-hub/common-specs/sdd-process.md` — it starts with `## Hub Branch Model` and covers: epic branches (short-lived, merged before execution), plan branches (one per task, lifecycle description with the draft→approved→execution→sync→ready flow), cross-PR linking format, and the own-SDD repo exception.

6. Add an **Architecture Documentation Rule** section. Copy from `marketplace-sdd-hub/common-specs/sdd-process.md` — the section titled with "The Problem" / "The Rule" / "Resolution Path". It defines that `application-overview.md` must stay lean, detailed docs live in `architecture-documentation/` or `documentation/<repo>/`, and agents must include doc update steps in plans.

7. Remove all references to `epics/active/` and `epics/done/` — replace with `epics/`.

---

### File 3: `common-specs/git-workflow.md`

**Read:** `sdd-boilerplate/common-specs/git-workflow.md`

**Apply these changes:**

1. Update the scope note at the top to add the hub-specific guidance reference:
   ```
   > **Scope:** These conventions apply to ALL repos managed by this hub (including the hub repo itself) unless a repo's own `sdd/agent-specs/git-workflow.md` overrides them.
   > For hub-specific operational guidance (when to commit in the hub, submodule management), see `agent-development/agent-specs/git-workflow.md`.
   ```

2. Update the feature branch format to use underscore (not hyphen) between ticket-id and description:
   ```
   - **Feature branches:** `<type>/<ticket-id>_<short-description>`
   ```

3. Update the branch examples to use underscore format and add hub branch types:
   ```
   # Target repo branches
   feat/PROJ-123_add-awards-endpoint
   fix/PROJ-456_null-check-awards
   chore/PROJ-789_update-dependencies

   # Hub branches
   epic/PROJ-55110_feature-name
   plan/PROJ-123_task-name
   ```

4. Add a **Hub-specific branch types** subsection under the branch naming section:
   ```
   ### Hub-specific branch types

   The hub repo uses two additional reserved types:

   | Type | Format | Purpose |
   |------|--------|---------|
   | `epic` | `epic/<ticket-id>_<description>` | Define an epic and its requests. Merged to `main` once the task graph is approved. |
   | `plan` | `plan/<ticket-id>_<description>` | One per task. Contains plan files, SDD state, and doc updates. Merged to `main` after execution is complete. |
   ```

---

### File 4: `common-specs/pr-conventions.md`

**Read:** `sdd-boilerplate/common-specs/pr-conventions.md`

**Apply these changes:**

Replace the generic multi-repo PR linking paragraph with a more precise version. Find the section about linking PRs across repos and replace with:

```
When a task produces a hub plan PR and a target repo PR:

**Hub plan PR description must include:**
```
**Target repo PR:** <org>/<repo>#<number>
```

**Target repo PR description must include:**
```
**Hub plan PR:** <org>/[hub-repo-name]#<number>
```

For epics spanning multiple repos, each PR links only to its direct counterpart. The hub's `delivery.yaml` is the authoritative record of all PRs across the epic.

`deploy_notes` in `delivery.yaml` documents any ordering requirements. A PR should NOT be merged if its `depends_on` PRs haven't merged yet.
```

---

### File 5: `epics/_templates/epic.md`

**Read:** `sdd-boilerplate/epics/_templates/epic.md`

**Apply these changes:**

1. In the YAML frontmatter, update the status comment to reflect simplified vocabulary:
   - Valid statuses: `pending`, `active`, `paused`, `ready-for-deployment`, `deployed`, `done`, `abandoned`
   - Initial status when epic is created: `pending`

2. Add EARS notation comment above the Success Criteria section:
   ```
   <!-- Notation: use EARS patterns for system/API-level criteria (e.g., "WHEN a vendor..., the system SHALL...") -->
   <!-- and Given/When/Then for behavioral/UI criteria. See common-specs/writing-specs.md for the full reference. -->
   ```

3. Add a **Definition of Done** section near the end (before any closing notes). Copy the section from `marketplace-sdd-hub/epics/_templates/epic.md` — it contains checkboxes for Deployment, Monitoring, Sign-offs, Documentation, Success metrics, and Manual steps, with a note that the section should be adjusted or removed if criteria don't apply.

---

### File 6: `epics/_templates/task-graph.md`

**Read:** `sdd-boilerplate/epics/_templates/task-graph.md`

**Apply these changes:**

1. Update the "Jira Ticket Creation" section guidance. Replace the current text (which says to create tickets after the task-graph is finalized) with:
   - Timing: after each task is refined via Prompt 7 (status moves to `refined`)
   - Rationale: at breakdown time, tasks are shells with minimal detail — tickets born then are barren and need heavy updates later
   - If Atlassian MCP is available: the agent creates the ticket automatically during Prompt 7

2. Add a **Content Standard** subsection pointing to `config/jira-ticket-templates.md` for the minimum ticket content standard (AC, context, dev notes, etc.)

3. Remove all `epics/active/` path references — replace with `epics/`.

---

### File 7: `agent-development/requests/_TEMPLATE-request.md`

**Read:** `sdd-boilerplate/agent-development/requests/_TEMPLATE-request.md`

**Apply these changes:**

1. Add `discovered_during` field to the YAML frontmatter, after the `depends_on` field:
   ```yaml
   discovered_during: null  # Plan ID that surfaced this work (e.g., "3-add-notifications"), or null if planned from the start
   ```

2. Replace the simple acceptance criteria comment/note with an expanded EARS comment block:
   ```
   <!-- Verifiable criteria that define "done" for this task. Added during refinement (Prompt 7).    -->
   <!-- See common-specs/writing-specs.md for the full EARS pattern reference.                        -->
   <!--                                                                                               -->
   <!-- System/API-level criteria → EARS notation (preferred):                                        -->
   <!--   WHEN <trigger>, the system SHALL <response>                                                 -->
   <!--   WHILE <state>, the system SHALL <behavior>                                                  -->
   <!--   IF <unwanted condition>, the system SHALL <response>                                        -->
   <!--   WHERE <feature flag>, the system SHALL <behavior>                                           -->
   <!-- UI/behavioral flow criteria → Given/When/Then                                                 -->
   <!--                                                                                               -->
   <!-- Quality bar: each criterion must be Specific, Testable, Independent, and Complete.            -->
   ```

3. Update the parent epic path reference from `epics/active/<hub_epic>/epic.md` to `epics/<hub_epic>/epic.md`.

---

### File 8: `agent-development/plans/_templates/specification.md`

**Read:** `sdd-boilerplate/agent-development/plans/_templates/specification.md`

**Apply these changes:**

1. **Remove** the `status: draft` field from the YAML frontmatter entirely.

2. Replace the comment about status with a prominent warning box:
   ```
   # ═══════════════════════════════════════════════════════════════════════════
   # APPROVAL: The ONLY place to check or set plan approval status is:
   #   manifest.yaml → plan_metadata.approval.status
   #
   # Do NOT add a status field here — it goes stale and misleads agents.
   # ═══════════════════════════════════════════════════════════════════════════
   ```

3. Update the Task Definition source path in the Context table from `sdd/agent-development/pending/<N>-<name>.md` to `sdd/agent-development/requests/<N>-<name>.md`.

4. In the completion checklist, replace the three archive-related steps:
   ```
   - [ ] Plan `status` in `manifest.yaml` set to `done` (the plan folder stays in place — do NOT move it)
   ```
   (Remove the lines about moving to `done/` and archiving the request)

---

### File 9: `user-development/STATUS-REFERENCE.md`

**Read:** `sdd-boilerplate/user-development/STATUS-REFERENCE.md`

**Apply these changes:**

Replace the entire epic status vocabulary table and state machine. The new simplified vocabulary is:

| Status | Meaning | Set by | Valid next statuses |
|--------|---------|--------|---------------------|
| `pending` | Defined and decomposed; not yet being actively worked | Human | `active`, `abandoned` |
| `active` | At least one task is in-progress | Human / Agent | `paused`, `ready-for-deployment` |
| `ready-for-deployment` | All PRs merged; awaiting deployment window and/or manual steps | Agent / Human | `deployed` |
| `deployed` | Code is live in production; manual steps (if any) may still be pending | Human | `done` |
| `done` | All code deployed; all `manual_steps` completed; feature is fully live | Human | _(terminal)_ |
| `paused` | Temporarily halted (external blocker, priority shift, or scope renegotiation) | Human | `active`, `abandoned` |
| `abandoned` | Will not be completed | Human | _(terminal)_ |

Add a note:
> **`done` gate:** An epic should remain at `deployed` until all entries in `delivery.yaml → manual_steps` have a non-null `completed_at`. Epics with no `manual_steps` can transition directly from `deployed` to `done`.

> **Deprecated statuses:** `draft`, `discussing`, `decomposed`, `renegotiating`, and `delivered` are no longer part of the canonical vocabulary. Existing epics using these values should be migrated to `pending` (for pre-active stages) or the appropriate new status.

Update the Mermaid state machine diagram to match the new vocabulary.

Update the archiving section to say: **Epics never move between directories.** All epics remain in `epics/`. The `status` field is the sole indicator of lifecycle state. Running `bin/dev wf:archive` updates the status to `done` in-place — no files move.

---

### File 10: `user-development/DEVELOPMENT-GUIDE.md`

**Read:** `sdd-boilerplate/user-development/DEVELOPMENT-GUIDE.md`

**Apply these changes:**

1. At the top of the file (after the main title/intro), add cross-reference links:
   ```
   > **Team flow:** For the end-to-end squad choreography integrating Figma, Jira, and GitHub, see [SQUAD_FLOW.md](./SQUAD_FLOW.md).
   >
   > **Auditing:** For delivery metrics, amendment tracing, and retrospective analysis, see [AUDITING-AND-METRICS.md](./AUDITING-AND-METRICS.md).
   ```

2. Add a **Why the Rules Exist — SDD Failure Modes** section after the intro/overview section (before the Directory Structure or Pipeline section). Copy from `marketplace-sdd-hub/user-development/DEVELOPMENT-GUIDE.md` — the section explaining `intent drift`, `context decay`, and `unverifiable output` with the table and the reference to `writing-specs.md`.

3. In the Directory Structure section, update:
   - `epics/active/` → `epics/`
   - Remove `epics/done/` entry
   - `agent-development/plans/done/` and `agent-development/requests/done/` → remove (no done subdirs)
   - Update `agent-development/pending/` → `agent-development/requests/`
   - Add `.agents/skills/` and `.github/prompts/` entries

4. In the epic planning table, update path: `epics/active/N-name/` → `epics/N-name/`

5. In the Epic Workflow section, replace all "Prompt N" references with "Skill `sdd-*`" references with "Prompt N" as fallback. Example: `sdd-create-epic` → description with `Prompt 5` noted as fallback.

6. Add `common-specs/writing-specs.md` to the spec cascade table at Priority 4.

7. Update the Sync Rule section to the 4-step version (same as AGENTS.md change above). Remove references to archiving plans to `done/`.

8. Update all `epics/active/` path references to `epics/`.

9. Update all `agent-development/pending/` references to `agent-development/requests/`.

10. Add a **Skills** section near the end (before or after the Prompts section). Copy from `marketplace-sdd-hub/user-development/DEVELOPMENT-GUIDE.md` — the section listing all 11 skills with their invocation methods by IDE.

---

### File 11: `config/jira-ticket-templates.md`

**Read:** `sdd-boilerplate/config/jira-ticket-templates.md`

**Apply these changes:**

1. Update the header note to clarify hub-level canonical status:
   ```
   > **Location:** `config/jira-ticket-templates.md` (hub root — canonical)
   > **Used by:** Prompt 7 (Refine Request), Prompt 5/6 (Epic Creation), Prompt 9 (Amend Epic)
   > **Purpose:** Defines the minimum content standard for Jira tickets created from SDD tasks and epics.
   > Jira tickets look the same regardless of target repo — this is the single hub-level template with no repo-level overrides.
   ```

2. Add a row to the "When to use which template" table:
   ```
   | After epic is confirmed and Jira epic needed | **Epic Ticket Template** | End of Prompt 5 / Prompt 6 |
   ```

3. In the Acceptance Criteria section of the task ticket template, replace the simple `Given/When/Then` bullets with EARS-annotated comment block:
   ```
   <!-- Use EARS notation for system/API-level criteria (preferred):         -->
   <!--   WHEN <trigger>, the system SHALL <response>                        -->
   <!--   IF <unwanted condition>, the system SHALL <response>               -->
   <!-- Use Given/When/Then for UI/behavioral flow criteria.                 -->
   <!-- See common-specs/writing-specs.md for the full EARS pattern reference. -->
   - [ ] [Criterion 1]
   - [ ] [Criterion 2]
   - [ ] [Criterion 3]
   ```

4. **Add the entire Epic Ticket Template section** at the end of the file. Copy verbatim from `marketplace-sdd-hub/config/jira-ticket-templates.md` — the section starting with `## Epic Ticket Template` through the end of the file. This section covers: title format, full description markdown template (Problem Statement, Product Vision, Success Metrics, Scope In/Out, Repos Involved, Links, Task Summary, Definition of Done), and the "When to Update the Epic Ticket" table.

---

### File 12: All prompts — add preferred-invocation headers

For each prompt file listed below, add the following header block at the very top of the file (before any existing content):

```markdown
> **🎯 Preferred invocation:** In Zed or Claude Code, describe what you want —
> the `sdd-<skill-name>` skill activates automatically. In VS Code, use `/sdd-<skill-name>`.
>
> **📋 Fallback:** Copy-paste the content below into any agent conversation.

---
```

Apply to these files (replace `<skill-name>` with the matching skill name):

| File | Skill name |
|------|-----------|
| `user-development/prompts/0-bootstrap-hub.md` | `sdd-bootstrap-hub` |
| `user-development/prompts/1-plan-task.md` | `sdd-plan-task` |
| `user-development/prompts/2-execute-plan.md` | `sdd-execute-plan` |
| `user-development/prompts/3-create-request.md` | `sdd-create-request` |
| `user-development/prompts/4-quick-fix.md` | `sdd-quick-fix` |
| `user-development/prompts/5-create-epic.md` | `sdd-create-epic` |
| `user-development/prompts/6-break-down-epic.md` | `sdd-break-down-epic` |
| `user-development/prompts/7-refine-epic-request.md` | `sdd-refine-request` |
| `user-development/prompts/8-dispatch-tasks.md` | `sdd-dispatch-tasks` |
| `user-development/prompts/9-amend-epic.md` | `sdd-amend-epic` |

(`9-retro-analysis.md` already has this header — skip it.)

---

### File 13: Additional prompt content changes (beyond the header)

After adding headers, apply these content-level changes to specific prompts:

#### `user-development/prompts/1-plan-task.md`

1. Update the task request path from `agent-development/pending/` to `agent-development/requests/`.
2. Add a **Context Freshness Check** section after the "Context to Read" section. Copy from `marketplace-sdd-hub/user-development/prompts/1-plan-task.md` — it covers: identify referenced docs, check last-modified via `git log -1`, flag stale docs (>90 days), check `metrics/<team-name>/cycles/` for recurring amendment patterns.
3. In the Output section, add the branch/PR creation steps after plan file creation (create branch, commit plan, open draft PR with `gh pr create --draft`).
4. Add the **Architecture Documentation Rule** section. Copy from `marketplace-sdd-hub/user-development/prompts/1-plan-task.md` — covers: assess impact, update relevant detailed doc (not overview), keep `application-overview.md` lean, include doc updates in plan stages.
5. Update the final instruction from "Present as code blocks and ask before saving" to "Write all plan files directly, then create branch, commit, push, open draft PR."

#### `user-development/prompts/2-execute-plan.md`

1. Add a **Fallback-SDD Repos: Submodule Setup** section. Copy from `marketplace-sdd-hub/user-development/prompts/2-execute-plan.md` — covers: when `has_own_sdd: false`, sync with `bin/dev repo:sync`, `cd repos/<repo-name>`, the two-directory model table (code ops in submodule, plan/delivery updates at hub root).
2. Update the sync/completion steps at the end to match the 4-step Sync Rule (plan `manifest.yaml → status: done`, task-graph → `done`, delivery.yaml → `ready-for-review`, hub PR → ready for review).

#### `user-development/prompts/3-create-request.md`

1. Update request path from `agent-development/pending/` to `agent-development/requests/` (all occurrences).
2. In the Context to Read list, add: `8. **Writing specs** — \`common-specs/writing-specs.md\` for EARS notation and acceptance criteria quality bar.`

#### `user-development/prompts/4-quick-fix.md`

1. Update the quick-fix log path from `agent-development/done/quick-fixes/` to `agent-development/quick-fixes/`.

#### `user-development/prompts/5-create-epic.md`

1. Update `epics/active/` → `epics/` in all path references.
2. In Context to Read, add: `8. **Writing specs** — \`common-specs/writing-specs.md\` for EARS notation.`
3. Update the initial status from `decomposed` to `pending` in the epic creation step.
4. In the output steps, add the Definition of Done section requirement (copy from hub's Prompt 5 — the four DoD criteria: production-ready, monitoring, sign-offs, success metrics).
5. Add EARS notation requirement for success criteria: "Write measurable success criteria using EARS notation for system/API-level criteria (see `common-specs/writing-specs.md`). Use Given/When/Then for behavioral/UI criteria."

#### `user-development/prompts/6-break-down-epic.md`

1. Update `epics/active/` → `epics/` in all path references.
2. Update request template path from `agent-development/pending/` to `agent-development/requests/`.
3. In Context to Read, add: `common-specs/writing-specs.md` (EARS patterns for preliminary ACs).
4. Add **Milestone alignment** paragraph to the task description: map tasks to milestones from the Software Design Document; each milestone corresponds to a merge-group in `delivery.yaml`. Ask user to provide milestones if not defined.
5. In the Rules list, add rule 10: "Include preliminary acceptance criteria — even at shell stage, write 2-3 high-level ACs per task. Use EARS notation for system/API-level criteria."
6. Update Jira ticket timing note at the bottom to say tickets are created after refinement (Prompt 7), not at breakdown. Add the full explanation paragraph with rationale.

#### `user-development/prompts/7-refine-epic-request.md`

1. Update `epics/active/` → `epics/` in all path references.
2. Update request template path from `agent-development/pending/` to `agent-development/requests/`.
3. In Phase 3 (Acceptance Criteria Draft), update the AC instruction to include EARS notation: "Use **EARS notation** for system and API-level criteria (preferred) — see `common-specs/writing-specs.md` for the five patterns and usage examples."

#### `user-development/prompts/8-dispatch-tasks.md`

1. Update `epics/active/` → `epics/` in all path references.
2. Update dispatch target paths from `pending/` to `requests/`:
   - `repos/<repo>/sdd/agent-development/requests/<N>-<name>.md`
   - `fallback-sdd/<repo>/agent-development/requests/<N>-<name>.md`

#### `user-development/prompts/9-amend-epic.md`

1. Update `epics/active/` → `epics/` in all path references.
2. In Context to Read, add: `9. **Writing specs** — \`common-specs/writing-specs.md\` for EARS notation when creating new request file shells.`

---

### File 14: `agent-development/agent-specs/application-overview.md`

**Read:** `sdd-boilerplate/agent-development/agent-specs/application-overview.md`

**Apply this change:**

Add a **Common Specs (Priority 4 — Hub Universal)** section. Copy from `marketplace-sdd-hub/agent-development/agent-specs/application-overview.md`. The section is a table listing all 4 Priority 4 spec files:

```markdown
## Common Specs (Priority 4 — Hub Universal)

These files in `common-specs/` apply to all repos managed by this hub and are resolved by the spec cascade at Priority 4:

| File | Purpose |
|---|---|
| `common-specs/git-workflow.md` | Branching, commit conventions, versioning |
| `common-specs/pr-conventions.md` | PR structure, review process, merge strategy |
| `common-specs/sdd-process.md` | SDD pipeline rules, blast radius, plan structure |
| `common-specs/writing-specs.md` | EARS notation, SDD failure mode taxonomy, acceptance criteria quality bar |
```

---

### File 15: `agent-development/agent-specs/architecture-breakdown.md`

**Read:** `sdd-boilerplate/agent-development/agent-specs/architecture-breakdown.md`

**Apply these changes:**

1. Update the directory tree to reflect the flat epic structure:
   - Replace `epics/active/` → `epics/`
   - Remove `epics/done/` entry
   - Update `agent-development/` tree: remove `done/` subdirs, replace `pending/` with `requests/`, add `quick-fixes/`
   - Add `.agents/skills/` entry
   - Add `.github/prompts/` entry

2. Add a **Skills Invocation (Hub-Level)** subsection describing the three-tier invocation:
   ```
   ### Skills Invocation (Hub-Level)

   .agents/skills/<name>/SKILL.md    ← canonical skill (Zed / Claude Code)
   .github/prompts/<name>.prompt.md  ← symlink alias (VS Code Copilot /sdd-* commands)
   user-development/prompts/<n>-*.md ← copy-paste fallback (any editor)
   ```

---

### File 16: `agent-development/agent-specs/git-workflow.md`

**Read:** `sdd-boilerplate/agent-development/agent-specs/git-workflow.md`

**Apply this change:**

Update the opening note/blockquote to clarify that branch naming rules are in `common-specs/git-workflow.md`:
```
> **This describes git conventions for the HUB REPO itself** (when to commit, what to commit, submodule management).
> For branch naming formats, commit message rules, and PR conventions that apply to ALL repos, see `common-specs/git-workflow.md`.
```

---

## Execution Notes for the Agent

- **Work only in `sdd-boilerplate/`** — do not modify `marketplace-sdd-hub/`
- **Preserve template language** — the boilerplate must stay generic. Do not introduce `TKMarketplace`, `GPMP`, `Thunders`, `tkww`, or any other Marketplace-specific terms
- **Read each file before editing** — use the diff descriptions above as guidance, not blind overwrite instructions
- **Prefer `edit_file` over `write_file`** — these are targeted edits to existing files
- **For hub references** — when copying sections from the hub, replace any Marketplace-specific examples with generic equivalents (e.g., `GPMP-123` → `PROJ-123`, `TKMarketplace` → `<repo-name>`)
- **Validate the final state** — after all edits, run `find sdd-boilerplate -name "*.md" | grep -v ".git" | sort` to confirm no unexpected files were added or removed
