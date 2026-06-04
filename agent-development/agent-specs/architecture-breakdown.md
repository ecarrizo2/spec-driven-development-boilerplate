# Architecture Breakdown — Hub Level

> **This file describes the hub's own structure, NOT any managed repo.**
> For repo-specific architecture, use `bin/dev resolve-spec architecture <repo-name>`.

## Hub Directory Structure

```
hub/
├── config/                        Configuration (repos.yaml, teams.yaml)
├── epics/                         Cross-repo epic planning artifacts
│   ├── _templates/                Templates for epic.md, task-graph.md, delivery.yaml
│   └── <epic-name>/               One folder per epic (e.g., GPMP-55110-review-snippets/)
│                              Naming: ordinal prefix (1-name/) until Jira epic exists,
│                              then optionally rename to Jira ID prefix (GPMP-12345-name/)
├── repos/                         Git submodules (one per managed repo)
├── fallback-sdd/                  SDD structures for repos without their own
├── common-specs/                  Universal conventions (git, PR, SDD process)
├── documentation/                 Per-repo architecture docs (fallback)
├── contracts/                     Cross-service interface specs
├── architectural-schemas/         System-level topology diagrams
├── agent-development/             Hub-level agent pipeline (this directory)
│   ├── agent-specs/               Hub context (you are here)
│   ├── pending/                   Hub-level task requests (rare — most go to repos)
│   ├── plans/                     Hub-level plans (status tracked in manifest.yaml)
│   └── quick-fixes/               Quick fix logs (no full plan needed)
├── .agents/                       Project-local agent skills (Zed / Claude Code)
│   └── skills/                    One subdirectory per skill (sdd-*)
├── .github/                       GitHub-specific files
│   └── prompts/                   Symlinks → .agents/skills/ for VS Code Copilot /sdd-* commands
├── bin/                           Hub CLI commands
└── user-development/              Human guides + copy-paste prompt fallbacks
```

## Key Patterns

### Skills Invocation (Hub-Level)

```
.agents/skills/<name>/SKILL.md    ← canonical skill (Zed / Claude Code)
.github/prompts/<name>.prompt.md  ← symlink alias (VS Code Copilot /sdd-* commands)
user-development/prompts/<n>-*.md ← copy-paste fallback (any editor)
```

### Spec Resolution Cascade

```
Task plan → Repo-level specs → Hub documentation → Common specs
```

### Fallback Pattern

```
repos/<name>/sdd/ exists? → Use it
Otherwise → Use fallback-sdd/<name>/
```

### Sync Contract

After every task execution:
1. Update local plan status (in target repo)
2. Update hub task-graph (status field)
3. Update hub delivery.yaml (PR URL)

## This Is NOT an Application

The hub has no runtime, no deployment, no build pipeline. It is purely a coordination and planning tool that lives on developer machines.
