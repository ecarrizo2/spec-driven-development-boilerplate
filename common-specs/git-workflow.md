# Git Workflow — Common Conventions

> **Scope:** These conventions apply to ALL repos managed by this hub unless a repo's own `sdd/agent-specs/git-workflow.md` overrides them.

## Branching Model

- **Main branch:** Defined per-repo in `config/repos.yaml` (usually `main` or `develop`)
- **Feature branches:** `<type>/<ticket-id>-<short-description>`
- **Branch types:** `feat`, `fix`, `chore`, `hotfix`, `refactor`, `docs`, `ci`

## Branch Naming Examples

```
feat/PROJ-123-add-awards-endpoint
fix/PROJ-456-null-check-awards
chore/PROJ-789-update-dependencies
```

## Commit Conventions

All commits follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `chore` | Maintenance (deps, config, no logic change) |
| `refactor` | Code restructure without behavior change |
| `docs` | Documentation only |
| `ci` | CI/CD pipeline changes |
| `test` | Adding or fixing tests |

### Scope

Use the module or area affected: `feat(awards): add v2 endpoint`

### One Commit Per Stage

When executing SDD plans, each stage produces exactly one commit. The commit message should reference the ticket ID (extracted from the branch name automatically by the commit-msg hook).

## Pull Requests

- PRs are always created as **drafts** first
- PR title follows conventional commit format
- PR description uses the template from `user-development/PR_TEMPLATE.md`
- Squash merge is the default strategy (configurable in `config/teams.yaml`)

## Cross-Repo Coordination

When an epic spans multiple repos:
- Each repo gets its own feature branch (independent branching strategy)
- The hub's `delivery.yaml` tracks all branches and their relationships
- PRs reference related PRs in other repos via description links
- Deployment ordering is noted in `deploy_notes` field and PR descriptions
