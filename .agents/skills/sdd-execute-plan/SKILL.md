---
name: sdd-execute-plan
description: Execute an approved implementation plan in this hub — creates a branch in the target repo, opens a draft PR, and runs each plan stage with verification checkpoints and the sync rule on completion.
---

## Identify the Plan

Determine which plan to execute:

1. **If you mentioned a specific folder** (e.g., "execute `agent-development/plans/3-migrate-prompts-to-skills/`") — use that path directly.
2. **If you mentioned a task name or number** — find the matching folder in `agent-development/plans/`.
3. **If unspecified** — list `agent-development/plans/` (exclude `_templates`) and ask which plan to execute.

State which plan you'll execute.

---

## Context to Read

1. **Agent specs** — all files in `agent-development/agent-specs/`
2. **Target repo's AGENTS.md** — `repos/<name>/AGENTS.md` if it exists. This is the authoritative source for that repo's coding style, build commands, framework-specific rules, and project conventions. It takes precedence over `fallback-sdd/<name>/agent-specs/agent-instructions.md` for anything coding-related. If no `AGENTS.md` exists in the submodule, read `fallback-sdd/<name>/agent-specs/agent-instructions.md` instead.
3. **Team config** — `config/teams.yaml` (hub-level conventions: co-author, merge strategy, Jira). For the target repo's **base branch**, read `config/repos.yaml` → `repositories.<name>.branches.default`. Do **not** use `fallback-sdd/<repo>/config/teams.yaml` for the base branch — it may be stale.
4. **The plan** — `manifest.yaml` and `specification.md` in the plan folder
   - If `specification.md` contains a **Symbol Index** section, run each grep pattern from it before beginning Stage 1. This primes your code map and lets you locate any class, method, or interface without reading full files top-to-bottom.
5. **Status reference** — `user-development/STATUS-REFERENCE.md`
6. **If part of an epic:** the `delivery.yaml` in the epic folder

---

## Fallback-SDD Repos: Submodule Setup

> **Skip this section** if `config/repos.yaml` shows `has_own_sdd: true` for the target repo.

If `has_own_sdd: false` (plan lives in `fallback-sdd/<repo>/agent-development/plans/`), the submodule at `repos/<repo>/` is the target for all code and git operations:

1. Confirm the submodule path in `config/repos.yaml` → `repositories.<name>.submodule_path`
2. Sync and initialize the submodule:
   ```
   bin/dev repo:sync <repo-name>
   ```
3. Move into the submodule for all git and code operations:
   ```
   cd repos/<repo-name>
   ```

**Two-directory model — fallback repos only:**

| What | Where |
|---|---|
| Branch checkout, commits, push, `gh pr create` | `repos/<repo-name>/` (submodule) |
| Plan archiving, `delivery.yaml` / `task-graph.md` updates, documentation updates | Hub root |

Pre-Flight Checks 4–6 below run **from within `repos/<repo-name>/`**.

`gh pr create --draft` targets the **submodule's remote** (e.g., `tkww/TKMarketplace`), not the hub. The hub plan PR is updated separately per the Sync Rule.

---

## Pre-Flight Checks

1. Verify `manifest.yaml` → `plan_metadata.approval.status == "approved"`
2. Verify no `PENDING` markers remain in `specification.md`
3. Read `config/teams.yaml` for commit conventions
4. Verify you are on the correct feature branch (created during planning)
5. Verify a draft PR already exists for this branch (created during planning)
6. If no branch/PR exists (legacy flow), create the branch and open a draft PR using `gh pr create --draft`

---

## Execution Protocol

**Before the first stage — mark execution started:**
- `manifest.yaml` → `plan_metadata.status: in-progress`
- If epic task: `task-graph.md` → this task's status: `in-progress` (from `approved`)
- If epic task: `delivery.yaml` → this node's `status: in-progress`
- Commit: `plan(status): execution started [<ticket-id>]` and push

For each stage:

1. **Read** the stage instruction file
2. **Present the commit plan** — show the table of planned commits
3. **Wait for my approval** of the commit plan
4. **Execute commit units** one at a time:
   - Implement the change
   - Run verification commands (lint, typecheck, tests as appropriate)
   - If pass → commit with conventional commit message + co-author trailer
   - If fail → fix (max 2 retries) or STOP
5. **API Checkpoint** — if stage has `api_checkpoint: true`:
   - Provide the curl/GraphQL command from the stage instructions
   - STOP and wait for my confirmation before proceeding
6. **After all commits pass** → update `manifest.yaml` (stage status: `done`, increment current_stage)
7. **Push to branch** — the draft PR updates automatically

After ALL stages complete:

1. Run full verification (build + test + lint + typecheck)
2. **Documentation update** (see section below)
3. **Decisions update** (see section below)
4. **Feedback & amendments** (see section below)
5. Mark PR as **ready for review** (no longer draft)
6. Update `manifest.yaml`: `plan_metadata.status: done` (the plan folder stays in place — do NOT move it)
7. Update the originating **request file** status to `done`:
   - For epic tasks: `epics/<epic>/requests/<N>-name.md`
   - For standalone tasks: `agent-development/requests/<N>-name.md`
   - Edit the `status:` field in the frontmatter
   - If already `done` or file not found, note this and continue
8. Final commit: `chore: <ticket-id> sync request and plan status`
9. If epic task: update `delivery.yaml` node status to `ready-for-review`
10. If epic task: update `task-graph.md` task status to `done`

---

## Documentation Update

1. **Create new docs if needed** — if introducing new modules, services, patterns, or significant behavior, create a new document in `documentation/<repo>/`. Each doc covers one concern.
2. **Keep `architecture-overview.md` lean** — it's a **gateway** linking to detailed docs. If adding more than 2-3 sentences, create a separate document and link to it.
3. **Update existing docs** — if modifying documented behavior, update those docs.
4. **Link from overview** — if you created a new doc, add a one-line entry + link in `architecture-overview.md`.

Priority order:
- New standalone doc > growing the overview
- Accurate existing docs > comprehensive new docs
- One focused doc > one sprawling doc

---

## Decisions Update

Ask: **did this task establish or change any hub-wide convention, pattern, naming standard, SDD process rule, or tool choice?**

- **If yes:** create or update ADR files in `decisions/`. Use the next sequential number. Follow the existing format: conclusion first, then why, then consequences.
- **If no:** skip.

Triggers that indicate a decision should be recorded:
- A new syntax, format, or notation is mandated (e.g., EARS, a naming convention, a schema change)
- A directory structure or lifecycle model changes (e.g., folder flattening, status vocabulary)
- The authoritative source for a class of content moves (e.g., templates centralized, prompts superseded by skills)
- A hub-wide rule is added or removed from `AGENTS.md` or `common-specs/`
- A new bin command or validation rule is introduced that defines permanent hub behavior

---

## Feedback & Amendments

**If execution revealed new requirements OUT OF SCOPE** (examples: missing env vars, stub modules, missing API endpoints, needed integration tests in another repo):

1. **Record the amendment** in the epic's `delivery.yaml` → `amendments:` section:
   ```yaml
   amendments:
     - date: YYYY-MM-DD
       discovered_in_task: <this-task-id>
       discovered_in_stage: <stage-number>
       type: new_requirement | missing_dependency | scope_gap | infra_need
       summary: "Brief description of what was discovered"
       action: request_created | ticket_created | epic_updated
       request_file: "requests/N-new-name.md"  # if created
       jira_ticket: null  # filled by human or MCP
   ```

2. **Create a new request** in the epic's `requests/` folder describing the discovered work

3. **Add a new task** to `task-graph.md` frontmatter (status: `draft`, depends_on: includes this task)

4. **Add a placeholder node** to `delivery.yaml` → `nodes:` (status: `planned`)

5. **Create a Jira ticket** (if MCP available) or mark as `jira_ticket: null # NEEDS CREATION`

6. **Update `epic.md`** if discovery changes scope or acceptance criteria

**If execution revealed NO new requirements:** Skip.

---

## Rules

- Do NOT write code before approval
- Do NOT skip verification steps
- Do NOT modify files outside the stage's blast_radius.write
- Do NOT force-push to the branch
- Do NOT merge the PR — humans merge manually
- Multiple commits per stage are expected
- If you discover something unexpected, classify it (info/question/blocker) and handle per `agent-workflow.md`

---

## Discovery Handling

If encountering something unexpected:

| Severity | Action |
|---|---|
| `info` | Log in manifest.yaml amendments, continue |
| `question` | Log in manifest.yaml, use safe default, flag for async review |
| `blocker` | Log in manifest.yaml, set status to `paused`, STOP and wait |
| `scope_impact` | Log in manifest.yaml, continue execution, handle in Feedback & Amendments section at the end |

For blockers: I'll edit the manifest with my decision, then resume.

For scope_impact: Do NOT stop execution. Complete the task, then record the amendment in Feedback & Amendments after all stages pass.
