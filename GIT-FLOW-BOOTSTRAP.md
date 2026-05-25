# Bootstrapping the Git-Native SDD Workflow

> **Audience:** Engineer setting up the git-native SDD workflow from scratch (or migrating from local mode).
>
> **Time estimate:** ~30 minutes for infrastructure setup + 5 minutes per target repo.
>
> **Prerequisites:** GitHub organization with admin access to repos, GitHub Copilot Business/Enterprise subscription with Cloud Agent enabled.

---

## Table of Contents

- [Overview](#overview)
- [Part 1: Hub Setup](#part-1-hub-setup)
- [Part 2: GitHub Authentication](#part-2-github-authentication)
- [Part 3: Target Repo Setup](#part-3-target-repo-setup)
- [Part 4: Labels & Branch Protection](#part-4-labels--branch-protection)
- [Part 5: Verify the Pipeline](#part-5-verify-the-pipeline)
- [Part 6: First Epic (End-to-End Test)](#part-6-first-epic-end-to-end-test)
- [Troubleshooting](#troubleshooting)

---

## Overview

The git-native workflow has two sides:

```
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│         HUB REPO                │       │       TARGET REPO(S)            │
│                                 │       │                                 │
│  epic-dispatch.yml              │──────▶│  plan-merged.yml                │
│  sync-status.yml                │◀──────│  alignment-check.yml            │
│                                 │       │  sync-hub.yml                   │
│  Secrets: ORG_TOKEN             │       │  copilot-setup-steps.yml        │
│  Variables: (none)              │       │                                 │
│                                 │       │  Secrets: HUB_TOKEN, LLM_API_KEY│
│                                 │       │  Variables: HUB_REPO            │
└─────────────────────────────────┘       └─────────────────────────────────┘
```

You need to set up both sides for the pipeline to work end-to-end.

---

## Part 1: Hub Setup

### 1.1 Scaffold the Hub (if new)

If you're starting fresh:

```bash
git clone <this-boilerplate-url> my-domain-hub
cd my-domain-hub
rm -rf .git
git init
git add .
git commit -m "chore: scaffold multirepo hub"
```

Push to GitHub:

```bash
gh repo create org/my-domain-hub --private --source=. --push
```

### 1.2 Verify Hub Workflows Exist

Confirm these files exist (they're included in the boilerplate):

```
.github/workflows/epic-dispatch.yml
.github/workflows/sync-status.yml
```

If you scaffolded from an older version of the boilerplate, copy them from this repo.

### 1.3 Configure `config/repos.yaml`

Replace the example entries with your actual repos. Each entry must have a valid `git_url` pointing to a GitHub repo (the dispatch action parses this to find the `owner/repo`):

```yaml
repositories:
  my-api:
    display_name: "My API"
    git_url: "git@github.com:my-org/my-api.git"  # ← must be a GitHub URL
    # ... rest of config
```

Also confirm the `hub:` section at the bottom has your actual hub repo:

```yaml
hub:
  repo: "my-org/my-domain-hub"   # ← your actual org/repo
```

### 1.4 Register Your Repos as Submodules

```bash
bin/dev repo:add my-api git@github.com:my-org/my-api.git
bin/dev repo:add my-frontend git@github.com:my-org/my-frontend.git
```

### 1.5 Bootstrap Context (Prompt 0)

Use `user-development/prompts/0-bootstrap-hub.md` with your agent to generate architecture docs and fallback specs. These get bundled into issues at dispatch time.

---

## Part 2: GitHub Authentication

The cross-repo communication requires tokens that can read/write across repositories.

### Option A: Personal Access Token (PAT) — Simplest

Create a **Fine-grained PAT** with access to all repos in the hub:

1. Go to **GitHub → Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens**
2. Click **Generate new token**
3. Configure:
   - **Token name:** `sdd-hub-orchestration`
   - **Expiration:** 90 days (set a calendar reminder to rotate)
   - **Repository access:** Select repositories → choose hub + all target repos
   - **Permissions:**
     - **Repository permissions:**
       - Contents: Read and write
       - Issues: Read and write
       - Pull requests: Read and write
       - Metadata: Read-only
4. Generate and copy the token

### Option B: GitHub App — More Secure (Recommended for Production)

1. Create a GitHub App in your org settings
2. Grant permissions: Contents (RW), Issues (RW), Pull requests (RW)
3. Install the app on all repos (hub + targets)
4. Generate a private key
5. Use a GitHub Action to generate installation tokens at runtime

See [GitHub docs: Creating a GitHub App](https://docs.github.com/en/apps/creating-github-apps).

### Configure Hub Secrets

In the **hub repo** on GitHub:

1. Go to **Settings → Secrets and variables → Actions**
2. Add repository secret:
   - **Name:** `ORG_TOKEN`
   - **Value:** Your PAT (or GitHub App token workflow)

### Configure Target Repo Secrets & Variables

In **each target repo** on GitHub:

1. **Settings → Secrets and variables → Actions → Secrets:**
   - **`HUB_TOKEN`** — Same PAT (or a scoped token with write access to the hub repo only)
   - **`LLM_API_KEY`** — *(Optional)* API key for the alignment check LLM (not needed if using GitHub Models)

2. **Settings → Secrets and variables → Actions → Variables:**
   - **`HUB_REPO`** — Value: `my-org/my-domain-hub` (the hub's `owner/repo`)

> **Tip:** If all target repos share the same org, you can use **Organization-level secrets** to avoid repeating this per repo.

---

## Part 3: Target Repo Setup

For each target repo, copy the template files and customize them.

### 3.1 Copy Template Files

From the hub repo root:

```bash
# Option A: Manual copy
cp -r target-repo-template/.github repos/my-api/.github
cp -r target-repo-template/sdd repos/my-api/sdd
cp target-repo-template/AGENTS.md repos/my-api/AGENTS.md

# Option B: If the command exists
# bin/dev repo:setup-gitflow my-api
```

Or from within the target repo itself:

```bash
cd /path/to/my-api
mkdir -p .github/workflows .github/instructions sdd/plans

# Copy workflows
cp /path/to/hub/target-repo-template/.github/workflows/* .github/workflows/
cp /path/to/hub/target-repo-template/.github/copilot-instructions.md .github/
cp /path/to/hub/target-repo-template/.github/instructions/* .github/instructions/
cp /path/to/hub/target-repo-template/AGENTS.md ./AGENTS.md
touch sdd/plans/.gitkeep
```

### 3.2 Customize `copilot-setup-steps.yml`

This workflow sets up the Copilot Cloud Agent's environment. Customize it for your repo's tech stack:

```yaml
# For a Python project:
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Install dependencies
        run: pip install -r requirements.txt

# For a Go project:
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: "1.22"
      - name: Install dependencies
        run: go mod download
```

### 3.3 Customize `.github/copilot-instructions.md`

Replace ALL placeholders with your actual repo information:

- `<Repo Name>` → your service name
- Tech stack → your actual stack
- Build commands → your actual commands
- Architecture → brief module overview
- Coding standards → key rules

**This file is critical** — it's the primary context Copilot reads when starting a session.

### 3.4 Customize `AGENTS.md`

Update the header and "Build & Verify" section with your repo's actual commands.

### 3.5 Customize Path Instructions

Edit `.github/instructions/sdd-execution.instructions.md`:
- Update `applyTo` if your source code lives somewhere other than `src/**,lib/**,test/**`

### 3.6 Commit & Push

```bash
git add .
git commit -m "chore: add git-native SDD workflow infrastructure"
git push
```

---

## Part 4: Labels & Branch Protection

### 4.1 Create Labels

In **each target repo**, create these labels (Settings → Labels, or via CLI):

```bash
# Using GitHub CLI
gh label create "sdd-plan" --color "0E8A16" --description "SDD planning phase" --repo org/my-api
gh label create "sdd-execute" --color "1D76DB" --description "SDD execution phase" --repo org/my-api
gh label create "alignment-checked" --color "FBCA04" --description "Alignment check completed" --repo org/my-api
```

For epic labels, create them as needed when epics are started:

```bash
gh label create "epic-1" --color "B60205" --description "Epic 1" --repo org/my-api
```

In the **hub repo**, also create:

```bash
gh label create "sdd-epic" --color "5319E7" --description "SDD epic definition" --repo org/my-domain-hub
```

### 4.2 Branch Protection (Target Repos)

In each target repo, go to **Settings → Branches → Branch protection rules → Add rule**:

| Setting | Value |
|---------|-------|
| Branch name pattern | `main` |
| Require pull request reviews | ✅ (at least 1 approval) |
| Require status checks to pass | ✅ (add your CI checks) |
| Require branches to be up to date | Optional (recommended) |
| Allow force pushes | ❌ |
| Allow deletions | ❌ |

**Important:** Ensure Copilot Cloud Agent can push to branches. Under "Restrict who can push to matching branches", do NOT block the app/bot that Copilot uses.

### 4.3 Enable Copilot Cloud Agent

1. Go to **Organization Settings → Copilot → Policies**
2. Ensure "Copilot coding agent" is enabled
3. In each target repo: **Settings → Code & automation → Copilot → Coding agent** → Enable

### 4.4 Auto-Delete Branches (Optional)

In each target repo: **Settings → General → Pull Requests**:
- ✅ Automatically delete head branches

The `plan-merged.yml` action will have already created the execution issue before the branch is deleted.

---

## Part 5: Verify the Pipeline

Run these checks to confirm everything is wired correctly.

### 5.1 Verify Hub Workflows

```bash
# In hub repo
gh workflow list --repo org/my-domain-hub
# Should show: "Epic Dispatch...", "Sync Status..."
```

### 5.2 Verify Target Repo Workflows

```bash
# In each target repo
gh workflow list --repo org/my-api
# Should show: "Copilot Setup Steps", "Plan Merged...", "Alignment Check", "Sync to Hub"
```

### 5.3 Verify Secrets Are Set

```bash
# Hub
gh secret list --repo org/my-domain-hub
# Should show: ORG_TOKEN

# Target repo
gh secret list --repo org/my-api
# Should show: HUB_TOKEN (and optionally LLM_API_KEY)

gh variable list --repo org/my-api
# Should show: HUB_REPO = org/my-domain-hub
```

### 5.4 Verify Labels Exist

```bash
gh label list --repo org/my-api | grep -E "sdd-plan|sdd-execute|alignment-checked"
```

### 5.5 Test Copilot Setup Steps

Trigger the workflow manually to verify the agent's environment builds:

```bash
gh workflow run "Copilot Setup Steps" --repo org/my-api
gh run list --workflow="Copilot Setup Steps" --repo org/my-api --limit 1
```

Wait for it to complete — if it fails, the Copilot Cloud Agent won't be able to operate.

---

## Part 6: First Epic (End-to-End Test)

### 6.1 Create a Test Epic

In the hub repo, create a small test epic manually (or use Prompt 9 in the Agents panel):

```bash
cd my-domain-hub
git checkout -b epic/1-test-workflow

mkdir -p epics/active/1-test-workflow/requests
```

Create minimal files:
- `epics/active/1-test-workflow/epic.md` — brief description
- `epics/active/1-test-workflow/task-graph.md` — one task with `status: refined`
- `epics/active/1-test-workflow/delivery.yaml` — one node
- `epics/active/1-test-workflow/requests/1-test-task.md` — simple request

### 6.2 Open & Merge the Epic PR

```bash
git add .
git commit -m "epic(1-test-workflow): test the git-native pipeline"
git push -u origin epic/1-test-workflow
gh pr create --title "epic(1-test-workflow): test the git-native pipeline" --label "sdd-epic"
gh pr merge --merge  # (or merge via UI after review)
```

### 6.3 Verify Dispatch

After the PR merges, check:

1. **Hub Actions tab:** `epic-dispatch.yml` should have run
2. **Target repo Issues:** A new issue titled `plan: <JIRA-ID> <task title>` should appear
3. **Issue details:** Assigned to `copilot`, labeled `sdd-plan` and `epic-1`

### 6.4 Watch Copilot Plan

If Copilot is properly configured, it should:
1. Pick up the issue
2. Create a branch `plan/...`
3. Open a Plan PR with files in `sdd/plans/`

### 6.5 Merge the Plan PR

Review and merge the Plan PR. Verify:
1. `plan-merged.yml` runs
2. A new issue appears titled `implement: ...` with label `sdd-execute`
3. Copilot picks it up and starts a Code PR

### 6.6 Verify Alignment Check

When the Code PR is marked ready for review:
1. `alignment-check.yml` should trigger
2. A PR review comment should appear with the alignment report

### 6.7 Merge & Verify Sync

Merge the Code PR. Verify:
1. `sync-hub.yml` runs
2. The hub's delivery manifest is updated (or a PR is opened on the hub)

---

## Troubleshooting

### "epic-dispatch.yml didn't create issues"

| Check | Fix |
|-------|-----|
| Did the PR actually merge (not just close)? | Ensure `merged == true` in the trigger |
| Is `ORG_TOKEN` set? | Add it in hub's Actions secrets |
| Does the token have `repo` scope for target repos? | Regenerate with correct permissions |
| Is `task.status` set to `refined` in task-graph? | Only `refined` tasks get dispatched |
| Does `config/repos.yaml` have the correct `git_url`? | Must be a valid `github.com` URL |

### "Copilot didn't pick up the issue"

| Check | Fix |
|-------|-----|
| Is the issue assigned to `copilot`? | Verify assignee in the issue |
| Is Copilot Cloud Agent enabled for this repo? | Check org and repo Copilot settings |
| Did `copilot-setup-steps.yml` pass? | Fix build failures in the setup workflow |
| Does the repo have `.github/copilot-instructions.md`? | Copy from template |

### "plan-merged.yml didn't create an execution issue"

| Check | Fix |
|-------|-----|
| Did the Plan PR change files in `sdd/plans/**`? | Path filter requires this |
| Did the PR actually merge? | Action only fires on `merged == true` |
| Can the action find `manifest.yaml`? | Check the JIRA-ID regex matches your ticket format |
| Does the workflow have `issues: write` permission? | Verify in workflow YAML |

### "alignment-check.yml didn't post a review"

| Check | Fix |
|-------|-----|
| Does the Code PR have the `sdd-execute` label? | Action filters on this label |
| Was the PR marked ready for review? | Action triggers on `ready_for_review` |
| Can the action read `specification.md`? | Check the plan path extraction regex |
| Is `LLM_API_KEY` configured? | Required if using external LLM (not GitHub Models) |

### "sync-hub.yml failed"

| Check | Fix |
|-------|-----|
| Is `HUB_TOKEN` set in target repo secrets? | Add it with write access to hub |
| Is `HUB_REPO` variable set? | Must be `owner/repo` format |
| Does the token have write access to the hub repo? | Verify token permissions |
| Did the Code PR have the `sdd-execute` label? | Action filters on this label |

---

## Checklist: Full Setup Complete

Use this as a final verification:

### Hub Repo
- [ ] `.github/workflows/epic-dispatch.yml` exists and is valid
- [ ] `.github/workflows/sync-status.yml` exists and is valid
- [ ] `config/repos.yaml` has all target repos with valid GitHub URLs
- [ ] `config/repos.yaml` has `hub.repo` set to `org/hub-name`
- [ ] Secret `ORG_TOKEN` is configured with cross-repo permissions
- [ ] Label `sdd-epic` exists
- [ ] Agent context bootstrapped (fallback-sdd, documentation, architectural-schemas)

### Each Target Repo
- [ ] `.github/workflows/copilot-setup-steps.yml` — customized for tech stack
- [ ] `.github/workflows/plan-merged.yml` — present
- [ ] `.github/workflows/alignment-check.yml` — present
- [ ] `.github/workflows/sync-hub.yml` — present
- [ ] `.github/copilot-instructions.md` — customized with repo details
- [ ] `.github/instructions/sdd-planning.instructions.md` — present
- [ ] `.github/instructions/sdd-execution.instructions.md` — `applyTo` matches source dirs
- [ ] `AGENTS.md` — customized with repo's build commands
- [ ] `sdd/plans/.gitkeep` — present (or `sdd/plans/` directory exists)
- [ ] Secret `HUB_TOKEN` — configured
- [ ] Variable `HUB_REPO` — set to `org/hub-name`
- [ ] Labels created: `sdd-plan`, `sdd-execute`, `alignment-checked`
- [ ] Branch protection on `main` — PR reviews required
- [ ] Copilot Cloud Agent enabled for this repo
- [ ] `copilot-setup-steps.yml` workflow passes when triggered manually

---

## Next Steps

Once setup is verified:

1. **Read `GIT-FLOW-DESIGN.md`** for the full architectural specification
2. **Use Prompt 9** (`user-development/prompts/9-create-epic-github.md`) to create your first real epic
3. **Monitor the first full cycle** — watch Actions logs and fix any issues
4. **Iterate on `.github/copilot-instructions.md`** — the better the context, the better Copilot's output
5. **Consider Organization secrets** — if you have many target repos, avoid repeating token setup
