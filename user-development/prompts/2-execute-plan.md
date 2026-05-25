# Prompt: Execute an Approved Plan

> **Usage:** Copy this prompt into a new agent conversation. Point it at an approved plan folder. The agent creates the branch, opens a draft PR, and executes stages progressively.

---

## Input

**Plan folder:** `agent-development/plans/<N-task-name>/`

---

## Context to Read

Before executing, read:

1. **Agent specs** — all files in `agent-development/agent-specs/`
2. **Team config** — `config/teams.yaml` (branching conventions, co-author)
3. **The plan** — `manifest.yaml` and `specification.md` in the plan folder
4. **Status reference** — `user-development/STATUS-REFERENCE.md`
5. **If part of an epic:** the `delivery.yaml` in the epic folder

---

## Pre-Flight Checks

Before writing any code:

1. Verify `manifest.yaml` → `plan_metadata.approval.status == "approved"`
2. Verify no `PENDING` markers remain in `specification.md`
3. Read `config/teams.yaml` for branch naming and commit conventions
4. Create the feature branch following the naming format in teams.yaml
5. Open a **draft PR** — first commit can be a reference to the plan (or empty commit with plan summary in body)

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
2. Mark PR as **ready for review** (no longer draft)
3. Update `manifest.yaml`: `plan_metadata.status: done`
4. Archive: move plan folder to `done/plans/`, request to `done/requests/`
5. Final commit: `chore: <ticket-id> archive completed plan and request`
6. If epic task: update `delivery.yaml` node status to `ready-for-review`
7. If epic task: update `task-graph.md` task status to `done`

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

If you encounter something unexpected:

| Severity | Action |
|---|---|
| `info` | Log in manifest.yaml amendments, continue |
| `question` | Log in manifest.yaml, use safe default, flag for async review |
| `blocker` | Log in manifest.yaml, set status to `paused`, STOP and wait |

For blockers: I'll edit the manifest with my decision, then resume with this same prompt.

---

## Git-Native Mode Adaptations

> If you are running as a GitHub Copilot Cloud Agent (triggered by a GitHub Issue with label `sdd-execute`), use these adaptations instead of the defaults above.

### Context Changes

- **DO NOT** check `approval.status` — the plan is approved because it's merged to `main`
- Read the plan from `sdd/plans/<task>/` on the current `main` branch
- Read the issue body for additional context (Jira ID, epic reference)

### Process Changes

- **DO NOT** wait for human approval of commit plans — execute autonomously
- Create branch `feat/<JIRA-ID>-<short-description>` and open a draft PR immediately
- Execute stages sequentially, committing and pushing incrementally
- Run verification after each stage (lint, typecheck, test)
- Mark PR as **ready for review** when all stages pass
- **DO NOT** archive locally (no `done/plans/`, `done/requests/` moves)

### Commit Convention

```
<type>(<scope>): <JIRA-ID> <description>

Co-authored-by: Copilot <noreply@github.com>
```

### What Stays the Same

- Stage-by-stage execution order
- Blast radius constraints
- Verification requirements (lint, typecheck, test)
- Discovery handling (info/question/blocker classification)
- Max 2 retries on test failures before stopping
