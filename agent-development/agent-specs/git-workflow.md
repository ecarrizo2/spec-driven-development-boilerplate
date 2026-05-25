# Git Workflow — Hub Level

> **This describes git conventions for the HUB REPO itself.**
> For conventions within managed repos, see `common-specs/git-workflow.md` or the repo's own git-workflow spec.

## Hub Branching

The hub repo itself uses a simple model:

- **`main`** — Stable state. All epics, configs, and documentation up to date.
- **Feature branches** — For hub-level changes (adding repos, updating templates, etc.)
- **No deployment branches** — The hub is never deployed.

## When to Commit in the Hub

| Action | Commit? | Message format |
|--------|---------|----------------|
| Add a new repo | Yes | `chore: add <repo-name> to hub` |
| Create/update an epic | Yes | `feat(epic): <epic-name> — <action>` |
| Dispatch a task | Yes | `chore(dispatch): task <N> → <repo>` |
| Update task status (done) | Yes | `chore(status): task <N> done in <repo>` |
| Update delivery.yaml (PR merged) | Yes | `chore(delivery): pr-<N> merged in <repo>` |
| Sync submodules | Usually no | Only commit if pinning a specific SHA |
| Update common-specs | Yes | `docs: update <spec-name>` |

## Submodule Management

**Never run raw git submodule commands.** Always use:
- `bin/dev repo:add` — Add a new submodule
- `bin/dev repo:sync` — Update to latest main
- `bin/dev repo:migrate` — Move fallback into child repo

The hub's `.gitmodules` tracks all submodules. The hub commits pin submodules at their main branch — they're updated on demand via `repo:sync`.

## Inside Managed Repos

When working inside `repos/<name>/` for task execution:
- Follow THAT repo's git conventions (from its own specs or `common-specs/git-workflow.md`)
- Branch naming: `<type>/<ticket-id>-<description>` (configured in `config/teams.yaml`)
- Commits: Conventional Commits, one per plan stage
- PRs: Always draft first, then promote to ready after verification
