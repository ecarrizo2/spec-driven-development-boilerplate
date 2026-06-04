# Pull Request Conventions

> **Scope:** These conventions apply to ALL repos managed by this hub unless overridden at the repo level.

## PR Lifecycle

1. **Draft PR** — Created by agent after plan execution begins
2. **Ready for Review** — Agent marks ready after all stages pass verification
3. **Review** — Human reviewer checks code, tests, and plan compliance
4. **Merge** — Squash merge into target branch (default)

## PR Title Format

```
<type>(<scope>): <description> [TICKET-ID]
```

Example: `feat(awards): add /v2/awards endpoint [PROJ-123]`

## PR Description Structure

Every PR description should include:

1. **What** — One-sentence summary of the change
2. **Why** — Link to the epic/request/Jira ticket
3. **How** — Brief technical approach (not a code walkthrough)
4. **Testing** — How to verify (commands, URLs, manual steps)
5. **Cross-repo notes** — If applicable: which other PRs must merge/deploy first

## Review Expectations

- Reviewer should check blast radius compliance (did the PR only touch declared files?)
- Reviewer should verify tests pass and coverage thresholds are maintained
- Reviewer should check for open questions that weren't resolved
- Use `bin/dev review <pr-number>` (in repo-level bin/dev) for a structured review packet

## Cross-Repo PRs

When a task produces a hub plan PR and a target repo PR:

**Hub plan PR description must include:**
```
**Target repo PR:** <org>/<repo>#<number>
```

**Target repo PR description must include:**
```
**Hub plan PR:** <org>/<hub-repo-name>#<number>
```

For epics spanning multiple repos, each PR links only to its direct counterpart. The hub's `delivery.yaml` is the authoritative record of all PRs across the epic.

`deploy_notes` in `delivery.yaml` documents any ordering requirements. A PR should NOT be merged if its `depends_on` PRs haven't merged yet.
