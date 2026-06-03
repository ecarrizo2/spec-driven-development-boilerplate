---
name: sdd-bootstrap-hub
description: Initialize hub context for this multirepo coordination hub — generate overview docs, commands config, fallback-sdd structures, and cross-service contracts for newly registered repos.
---

## Identify the Scope

Before starting, determine what to bootstrap:

1. **If you described a new repo to add** — confirm the repo name and git URL, then proceed.
2. **If bootstrapping an existing hub** — read `config/repos.yaml` to see what's registered and what's already scaffolded.
3. **If unspecified** — run `bin/dev repo:list` to see current state, then ask which repos need bootstrapping.

State which repos you'll bootstrap (new scaffolding or updating existing) before proceeding.

## Instructions

I'm bootstrapping the multirepo hub for **[DOMAIN/PROJECT NAME]**.

### My Repos

_List all repositories that will be managed by this hub:_

| Repo name | Git URL | Role/Description | Tech Stack |
|-----------|---------|------------------|-----------|
| `[repo-name]` | `git@github.com:[org]/[repo-name].git` | [Primary role — e.g., "Frontend — React SSR app"] | [e.g., TypeScript, Next.js, pnpm] |
| `[repo-name]` | `git@github.com:[org]/[repo-name].git` | [API role — e.g., "GraphQL API for data access"] | [e.g., NestJS, GraphQL, PostgreSQL] |

### How They Connect

_Describe the inter-service dependency graph:_

- `[repo-a]` → `[repo-b]`: [e.g., "Frontend calls API via GraphQL for data"]
- `[repo-b]` → `[data-store]`: [e.g., "API queries PostgreSQL for records"]

### Which Repos Have SDD Already?

_For each repo, indicate whether it has its own `sdd/` directory or uses hub fallback:_

- `[repo-name]`: **Yes** (own `sdd/` on main branch) / No (fallback in hub — `fallback-sdd/[repo-name]/`)

### Team Info

- **Team name:** [TEAM_NAME]
- **Jira project key:** [PROJ]
- **Jira board ID:** [BOARD_ID]
- **Default branch name:** [main / develop / qa — or specify per-repo]
- **Merge strategy:** [Squash merge / Merge commit / Rebase]
- **Branch format:** `<type>/<PROJ-123>_<short-description>`
- **Default Jira labels:** `["[TEAM_NAME]"]`
- **Default Jira components:** `["[COMPONENT]"]`

### QA/Dev URLs

_Optional — list environment URLs useful for agent verification steps:_

| Service | URL | Type |
|---------|-----|------|
| [Service name] | https://[your-qa-url] | QA environment |

### Key Domain Concepts

_Define 3-6 core domain concepts agents must understand to work in this codebase:_

- **[Concept]** — [One sentence definition]
- **[Concept]** — [One sentence definition]

---

## What You Should Generate

1. **`config/repos.yaml`** — Register each repo with name, git URL, SDD status, and default branch
2. **`config/teams.yaml`** — Team settings: Jira project key, board ID, branch format, merge strategy, co-author trailer
3. **Add git submodules** — Run `bin/dev repo:add <name> <url>` for each repo
4. **`architectural-schemas/system-overview.md`** — Mermaid diagram of the service topology
5. **`documentation/<repo>/overview.md`** — Generate a concise overview for each repo by reading its source code via the submodule
6. **`fallback-sdd/<repo>/config/commands.yaml`** — Detect build/test/lint commands from each repo's `package.json` (or equivalent) for repos using fallback SDD
7. **Cross-service contracts** — Generate `contracts/` specs for any shared API interfaces between services (field mappings, query patterns, event schemas)
8. **Verify structure** — Run `bin/dev repo:list` to confirm everything is registered

### Guidelines

- Read each repo's source code (via the submodule at `repos/<name>/`) to generate accurate specs
- Use the repo's `package.json` (or equivalent) to detect build/test/lint commands
- For repos WITH existing `sdd/` (`has_own_sdd: true`), don't modify — just verify
- Keep descriptions concise but complete enough for an agent to understand the system
- If `documentation/` folders already have detailed architecture docs, don't duplicate — just index them in the overview
