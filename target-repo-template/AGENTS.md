# <Repo Name> — Rules for AI Coding Agents

> **Replace** this with your repository name and description.

---

## Git-Native SDD Mode

This repo uses the Git-Native SDD workflow. Key differences from local SDD:

### Plan Phase

- You receive work via GitHub Issues (assigned to you with label `sdd-plan`)
- Create a branch `plan/<JIRA-ID>-<description>` and open a PR with plan files only
- The issue body contains all context you need (epic, request, specs)
- Do NOT write code during the plan phase

### Execution Phase

- You receive work via GitHub Issues (assigned to you with label `sdd-execute`)
- The plan is already approved and on `main` — read it from there
- Create a branch `feat/<JIRA-ID>-<description>` and implement the plan
- Push commits incrementally, the draft PR updates automatically
- Mark ready for review only after all stages pass verification

### Commit Convention

```
<type>(<scope>): <JIRA-ID> <description>

Co-authored-by: Copilot <noreply@github.com>
```

### Branch Naming

- Plan branches: `plan/<JIRA-ID>-<short-description>`
- Code branches: `feat/<JIRA-ID>-<short-description>`
- Hotfix branches: `fix/<JIRA-ID>-<short-description>`

---

## Build & Verify

```bash
pnpm install          # Install dependencies
pnpm build            # Compile
pnpm test             # Run tests
pnpm lint             # Lint check
pnpm tsc --noEmit     # Type check
```

---

## Rules

1. **No code without an approved plan.** Plan PRs contain only docs; Code PRs implement the plan.
2. **Source code is the source of truth.** If code contradicts a spec, code wins.
3. **Blast radius constraints apply.** Only touch files declared in the plan.
4. **Run verification after every stage.** lint + typecheck + test must pass.
5. **Commit incrementally.** One logical unit per commit, conventional commit format.
6. **Never force-push.** Preserve history for review.
7. **Never merge your own PR.** Humans merge after review.
