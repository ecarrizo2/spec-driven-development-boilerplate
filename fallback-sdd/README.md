# Fallback SDD Structures

This directory contains SDD (Spec-Driven Development) structures for repos that **don't have their own `sdd/` directory** internally.

## How It Works

When a task targets a repo without its own `sdd/`:
- Plans, requests, and execution artifacts live HERE instead of in the repo
- The structure mirrors what would exist inside `<repo>/sdd/` if it had one
- Agents use `fallback-sdd/<repo-name>/` exactly as they would use `<repo>/sdd/`

## Structure Per Repo

```
fallback-sdd/
└── <repo-name>/
    ├── agent-development/
    │   ├── agent-specs/          ← Architecture, coding standards for this repo
    │   │   ├── agent-instructions.md
    │   │   ├── agent-workflow.md
    │   │   ├── application-overview.md
    │   │   ├── architecture-breakdown.md
    │   │   └── git-workflow.md
    │   ├── pending/              ← Dispatched task requests land here
    │   ├── plans/                ← Active plans for this repo
    │   │   └── _templates/       ← (uses same templates as main SDD)
    │   └── done/                 ← Completed plans archive
    │       ├── plans/
    │       ├── requests/
    │       └── quick-fixes/
    └── config/
        └── commands.yaml         ← Build/test/lint commands for this repo
```

## Migration

When a repo adopts SDD internally, run:
```bash
bin/dev repo:migrate <repo-name>
```

This will:
1. Copy `fallback-sdd/<repo-name>/` contents into `repos/<repo-name>/sdd/`
2. Create a `chore/adopt-sdd` branch in the child repo
3. Open a PR in the child repo with the SDD structure
4. Update `config/repos.yaml` to set `has_own_sdd: true`
5. Remove `fallback-sdd/<repo-name>/` from the hub

## Resolution Rule

For any SDD operation targeting `<repo>`:
1. Check: does `repos/<repo>/sdd/` exist?
2. If YES → use it (repo is self-sufficient)
3. If NO → use `fallback-sdd/<repo>/` (hub provides structure)
