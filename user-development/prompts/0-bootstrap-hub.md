# Prompt 0: Bootstrap a Multirepo Hub

> **When to use:** Once — when setting up a new hub for your domain/project.
>
> **Actor:** Human provides context, agent generates all artifacts.
>
> **Prerequisite:** You've cloned the template, deleted `.git`, and initialized a fresh repo. You have the git URLs for your repos.

---

## Instructions

I'm setting up a new multirepo hub for **[DOMAIN/PROJECT NAME]**.

### My Repos

_List all repositories that will be managed by this hub:_

| Repo name | Git URL | Role/Description | Tech Stack |
|-----------|---------|------------------|-----------|
| `repo-1` | `git@github.com:org/repo-1.git` | _e.g., "Backend API for awards"_ | _e.g., NestJS, TypeScript, PostgreSQL_ |
| `repo-2` | `git@github.com:org/repo-2.git` | _e.g., "React frontend"_ | _e.g., React, TypeScript, Vite_ |
| ... | ... | ... | ... |

### How They Connect

_Describe how these services communicate:_

- `repo-1` → `repo-2`: _e.g., "Frontend calls API via REST/GraphQL"_
- `repo-1` → SQS: _e.g., "Publishes award events to a queue"_
- `repo-3` (infra): _e.g., "Provisions the database and queues used by repo-1"_

### Which Repos Have SDD Already?

- `repo-1`: _Yes / No_
- `repo-2`: _Yes / No_

### Team Info

- **Team name:** _e.g., "Thunders"_
- **Jira project key:** _e.g., "PROJ"_
- **Default branch name:** _e.g., "main" (or varies per repo?)_
- **Merge strategy:** _e.g., "squash"_

---

## What You Should Generate

1. **`config/repos.yaml`** — Full registry with all repos, their metadata, and topology
2. **`config/teams.yaml`** — Team config with Jira integration
3. **Add git submodules** — Run `git submodule add` for each repo
4. **`architectural-schemas/system-overview.md`** — Mermaid diagram showing service topology
5. **`documentation/<repo>/overview.md`** — One per repo, populated from my descriptions
6. **`fallback-sdd/<repo>/`** — Full SDD structure for repos that don't have their own:
   - `agent-development/agent-specs/` (generate by reading the repo's source code)
   - `agent-development/pending/`, `plans/`, `done/`
   - `config/commands.yaml` (detect from the repo's package.json or equivalent)
7. **Verify structure** — Run `bin/dev repo:list` to confirm everything is registered

### Guidelines

- Read each repo's source code (via the submodule) to generate accurate agent-specs
- Use the repo's `package.json` (or equivalent) to detect build/test/lint commands
- For repos WITH existing `sdd/`, don't create fallback — just register them
- The system-overview diagram should show all services and their connection types
- Keep descriptions concise but complete enough for an agent to understand the system
