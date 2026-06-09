---
name: sdd-execute-plan
description: Execute an approved implementation plan in this hub — creates a branch in the target repo, opens a draft PR, and runs each plan stage with verification checkpoints and the sync rule on completion.
---

## Identify the Plan

Before starting, determine which plan to execute:

1. **If you mentioned a specific folder** (e.g., "execute `agent-development/plans/3-migrate-prompts-to-skills/`") — use that path directly.
2. **If you mentioned a task name or number** — find the matching folder in `agent-development/plans/`.
3. **If unspecified** — list `agent-development/plans/` (exclude `_templates`) and ask which plan to execute.

State which plan you'll be executing before proceeding.

---

## Context to Read

Before executing, read:

1. **Agent specs** — all files in `agent-development/agent-specs/`
2. **Team config** — `config/teams.yaml` (hub-level conventions: co-author, merge strategy, Jira). For the target repo's **base branch**, read `config/repos.yaml` → `repositories.<name>.branches.default`. Do **not** use `fallback-sdd/<repo>/config/teams.yaml` for the base branch — it may be stale.
3. **The plan** — `manifest.yaml` and `specification.md` in the plan folder
4. **Status reference** — `user-development/STATUS-REFERENCE.md`
5. **If part of an epic:** the `delivery.yaml` in the epic folder

---

## Fallback-SDD Repos: Submodule Setup

> **Skip this section** if `config/repos.yaml` shows `has_own_sdd: true` for the target repo. For own-SDD repos, the plan, branch, and code all live in the same repo and no extra steps are needed.

If `has_own_sdd: false` (plan lives in `fallback-sdd/<repo>/agent-development/plans/`), the submodule at `repos/<repo>/` is the target for all code and git operations. Before any git or code work:

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

Pre-Flight Checks 4–6 below (branch and PR verification) run **from within `repos/<repo-name>/`**.

When `gh pr create --draft` runs it targets the **submodule's remote** (e.g., `<org>/<repo-name>`), not the hub. The hub plan PR (`plan/` branch) is updated separately after execution as part of the Sync Rule.

---

## Pre-Flight Checks

Before writing any code:

1. Verify `manifest.yaml` → `plan_metadata.approval.status == "approved"`
2. Verify no `PENDING` markers remain in `specification.md`
3. Read `config/teams.yaml` for commit conventions
4. Verify you are on the correct feature branch (created during planning)
5. Verify a draft PR already exists for this branch (created during planning)
6. If no branch/PR exists (legacy flow), create the branch and open a draft PR using `gh pr create --draft`

---

## Execution Protocol

For each stage (in order):

1. **Read** the stage instruction file
2. **Present the commit plan** to me — show the table of planned commits before writing code
3. **Wait for my approval** of the commit plan
4. **Execute commit units** one at a time:
   - Implement the change
   - Run verification commands (lint, typecheck, tests as appropriate)
   - If pass → commit with conventional commit message + co-author trailer
   - If fail → fix (max 2 retries) or STOP
5. **API Checkpoint** — if stage has `api_checkpoint: true`:
   - Provide the curl/GraphQL command from the stage instructions
   - STOP and wait for my confirmation before proceeding
6. **After all commits in stage pass** → update `manifest.yaml` (stage status: `done`, increment current_stage)
7. **Push to branch** — the draft PR updates automatically

After ALL stages complete:

1. Run full verification (build + test + lint + typecheck)
2. **Documentation update** (see section below)
3. **Feedback & amendments** (see section below)
4. Mark PR as **ready for review** (no longer draft)
5. Update `manifest.yaml`: `plan_metadata.status: done` (the plan folder stays in place — do NOT move it)
6. Final commit: `chore: <ticket-id> task complete`
7. If epic task: update `delivery.yaml` node status to `ready-for-review`
8. If epic task: update `task-graph.md` task status to `done`

---

## Documentation Update

After all stages pass and before marking the PR ready:

1. **Create new docs if needed** — if the implementation introduces new modules, services, patterns, or significant behavior, create a new document in the repo's `documentation/` folder (at hub level: `documentation/<repo>/`). Each doc should cover one concern.
2. **Keep `architecture-overview.md` lean** — the overview file in `agent-specs/` is a **gateway** that links to detailed docs, not a dumping ground. If you find yourself adding more than 2-3 sentences to it, create a separate document and link to it instead.
3. **Update existing docs** — if the change modifies behavior documented elsewhere, update those docs to match the new reality.
4. **Link from overview** — if you created a new doc, add a one-line entry + link in `architecture-overview.md`.

Priority order:
- New standalone doc > growing the overview
- Accurate existing docs > comprehensive new docs
- One focused doc > one sprawling doc

---

## Feedback & Amendments

After all stages pass and documentation is updated, review your discoveries:

**If execution revealed new requirements that are OUT OF SCOPE for this task** (examples: missing env vars that need infra work, modules that are stubs needing implementation, API endpoints that don't exist yet, new integration tests needed in another repo):

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

5. **Create a Jira ticket** (if MCP is available) or mark as `jira_ticket: null # NEEDS CREATION`

6. **Update `epic.md`** if the discovery changes the epic's scope or acceptance criteria

This step ensures that no discovered work is lost and that the audit trail connects execution back to planning.

**If execution revealed NO new requirements:** Skip this section.

---

## Rules

- Do NOT write code before I approve the commit plan
- Do NOT skip verification steps
- Do NOT modify files outside the stage's blast_radius.write
- Do NOT force-push to the branch
- Do NOT merge the PR — humans merge manually
- Multiple commits per stage are expected and encouraged
- If you discover something unexpected, classify it (info/question/blocker) and handle per `agent-workflow.md`

---

## Discovery Handling

If you encounter something unexpected during execution:

| Severity | Action |
|---|---|
| `info` | Log in manifest.yaml amendments, continue |
| `question` | Log in manifest.yaml, use safe default, flag for async review |
| `blocker` | Log in manifest.yaml, set status to `paused`, STOP and wait |
| `scope_impact` | Log in manifest.yaml, continue execution, handle in Feedback & Amendments section at the end |

For blockers: I'll edit the manifest with my decision, then resume with this same prompt.

For scope_impact: Do NOT stop execution. Complete your current task. Then record the amendment in the Feedback & Amendments section after all stages pass. This ensures the current task ships cleanly while the discovered work is properly queued.
