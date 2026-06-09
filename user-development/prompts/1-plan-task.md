> **🎯 Preferred invocation:** In Zed or Claude Code, describe what you want —
> the `sdd-plan-task` skill activates automatically. In VS Code, use `/sdd-plan-task`.
>
> **📋 Fallback:** Copy-paste the content below into any agent conversation.

---

# Prompt: Plan a Task

> **Usage:** Copy this prompt into a new agent conversation. Point it at an activated request in `agent-development/requests/`. The agent produces a plan folder ready for human review.

---

## Input

**Task request to plan:** `agent-development/requests/<N-task-name.md>`

---

## Context to Read

Before planning, read and internalize:

1. **Agent specs** — all files in `agent-development/agent-specs/`
2. **Team config** — `config/teams.yaml`
3. **The task request** — the file specified above (including YAML frontmatter)
4. **Plan templates** — `agent-development/plans/_templates/manifest.yaml`, `specification.md`, `stage.md`
5. **Status reference** — `user-development/STATUS-REFERENCE.md`
6. **Relevant source code** — files/modules implied by the request's Implementation Details
7. **If part of an epic:** the epic's `epic.md`, `task-graph.md`, and `delivery.yaml`
8. **Past metrics (if available):** check `metrics/thunders/cycles/` for patterns from previous epics

---

## Context Freshness Check

Before producing the plan, verify that the architecture docs you’re relying on are current:

1. **Identify referenced docs** — which files in `agent-specs/` or `documentation/<repo>/` describe the area you’re about to modify?
2. **Check last-modified dates** — run `git log -1 --format="%ci" -- <doc-path>` for each
3. **Flag stale docs** — if a doc hasn’t been updated in >90 days AND your plan touches that area:
   - Note it as an Open Question: “Doc `XX-name.md` may be outdated — verify during execution”
   - Add a documentation-update step to the plan’s final stage
4. **Check amendment patterns** — if `metrics/thunders/cycles/` shows recurring `missing_dependency` or `infra_need` amendments for this repo, add a verification step for those areas to your plan

---

## Your Task

Produce a complete plan folder in `agent-development/plans/<N-task-name>/`.

After producing the plan, you must also:
1. **Create a feature branch** from `main` following the naming convention in `config/teams.yaml`
2. **Commit the plan folder** to the branch
3. **Push the branch and open a draft PR** using the `gh` CLI:
   ```bash
   gh pr create --draft --title "plan: <ticket-id> <short-description>" --body "Plan for review. See specification.md for details."
   ```

The folder must contain:

### 1. `manifest.yaml`

- Populate all fields from the template
- Set `plan_metadata.status: pending-approval`
- Set `plan_metadata.approval.status: pending`
- Set `plan_metadata.complexity` from the request's frontmatter
- Set `plan_metadata.api_checkpoint` from the request's frontmatter
- Define 2-5 stages with blast radius, verification commands, and rollback plans
- Per-stage `complexity` using Fibonacci scale
- Per-stage `api_checkpoint: true` if that stage changes observable API behavior
- For standalone tasks (no epic): fill the `delivery` section with planned branch name

### 2. `specification.md`

- Fill YAML frontmatter (plan_id, title) — **do NOT add a `status` field** (approval lives only in `manifest.yaml`)
- Populate all body sections from the template
- Write thorough Open Questions for anything you cannot decide autonomously
- Include the File Manifest with all files across all stages
- Include API Checkpoint details in relevant stage summaries (the curl/GraphQL command and expected response shape — these are approved at plan time)

### 3. Stage instruction files

- One file per stage following `stage.md` template
- Include a commit plan (table of: commit message, files, purpose)
- Each stage should have **multiple commit units** if the work is decomposable
- Step-by-step instructions with file paths, code snippets, shell commands
- "Spec & doc review" steps in the last stage only (or inline for single-stage)

---

## Constraints

- Blast radius MUST stay within the request's stated scope
- If you find a missing dependency, write it as an Open Question (don't guess)
- Every `.ts` source change needs a corresponding test update or new test
- Prisma schema changes get their own stage
- Multiple commits per stage are expected — plan them explicitly in the commit table

### Architecture Documentation Rule

Every plan MUST include a documentation assessment and, when applicable, doc update steps:

1. **Assess impact:** Determine if the plan changes observable behavior, data flow, component patterns, API interfaces, or introduces new modules/patterns.

2. **Update the relevant detailed doc** (NOT the overview):
   - If a relevant doc exists in `architecture-documentation/` (repo-local) or `documentation/<repo>/` (hub fallback), update it with the new patterns/changes.
   - If no relevant doc exists and the change introduces a **new architectural area**, create a new numbered doc (e.g., `20-new-area.md`) following the existing naming convention.

3. **Keep `application-overview.md` lean:**
   - The overview in `agent-specs/application-overview.md` is a **mandatory read** for every agent session. It MUST NOT grow with implementation details.
   - It should only contain: purpose, core workflow summaries (2–3 sentences each), and **pointers** to the detailed docs (`**Architecture doc:** \`XX-name.md\``).
   - If your plan introduces a new workflow or module that deserves mention in the overview, add only a short summary + pointer — never inline the detail.

4. **Include doc updates in the plan stages:**
   - Add a "Documentation update" step in the final stage (or as a dedicated commit in the commit table).
   - List which doc files will be created or modified.
   - The commit message should be: `docs: update architecture-documentation for <feature/area>`

This rule applies to ALL repos — whether they use their own `sdd/` + `architecture-documentation/`, or the hub's `fallback-sdd/` + `documentation/<repo>/`.

---

## Output

Write all plan files directly without asking for confirmation first. Then:

1. **Create the branch** from `main` following the naming convention in `config/teams.yaml`
2. **Commit the plan folder** to the branch
3. **Push and open a draft PR:**
   ```bash
   gh pr create --draft --title "plan: <ticket-id> <short-description>" --body "Plan for review. See specification.md for details."
   ```
4. **Remind me:**
> "Draft PR is open at `<pr-url>`. Review `specification.md`, resolve any `PENDING` questions by editing the files directly or commenting on the PR, then set `manifest.yaml` → `approval.status: approved` when ready to execute."
