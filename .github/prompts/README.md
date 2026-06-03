# `.github/prompts/` — VS Code Copilot Prompt Aliases

This directory contains symlinks that enable VS Code Copilot to invoke SDD workflow skills via slash commands (e.g., `/sdd-plan-task`).

## How It Works

```
Canonical source of truth
.agents/skills/<name>/SKILL.md
        │
        └── symlinked as .github/prompts/<name>.prompt.md
                │
                └── VS Code Copilot discovers as /sdd-<name>
```

Each `.prompt.md` file here is a symlink — not a copy. Editing the skill in `.agents/skills/` automatically updates what VS Code sees.

## Available Skills

| VS Code Command | Skill | Purpose |
|---|---|---|
| `/sdd-bootstrap-hub` | `sdd-bootstrap-hub` | Initialize hub context for registered repos |
| `/sdd-plan-task` | `sdd-plan-task` | Create implementation plan from activated request |
| `/sdd-execute-plan` | `sdd-execute-plan` | Execute an approved plan |
| `/sdd-create-request` | `sdd-create-request` | Interactive discovery → write standalone request |
| `/sdd-quick-fix` | `sdd-quick-fix` | Small, obvious change (1–3 files, no design decisions) |
| `/sdd-create-epic` | `sdd-create-epic` | Interactive discovery → write cross-repo epic |
| `/sdd-break-down-epic` | `sdd-break-down-epic` | Decompose epic into task graph + delivery manifest |
| `/sdd-refine-request` | `sdd-refine-request` | Refine epic task shell → full request + Jira ticket |
| `/sdd-dispatch-tasks` | `sdd-dispatch-tasks` | Dispatch refined tasks to target repos |
| `/sdd-amend-epic` | `sdd-amend-epic` | Interactively amend an in-flight epic |
| `/sdd-retro-analysis` | `sdd-retro-analysis` | Retrospective analysis on completed epic metrics |

## Invocation by IDE

| IDE | How to Invoke |
|---|---|
| **Zed** | Describe what you want naturally — the agent matches the skill by its description |
| **Claude Code** | Same as Zed — intent-based matching |
| **VS Code Copilot** | Type `/sdd-<name>` in the chat input |
| **Cursor / other** | Copy-paste from `user-development/prompts/` (copy-paste fallback) |

## Maintaining This Directory

- To **add a skill**: create the skill in `.agents/skills/<name>/SKILL.md`, then add a symlink here.
- To **rename a skill**: update the symlink (and the skill directory) atomically — broken symlinks cause VS Code to ignore the prompt.
- To **verify all symlinks are valid**: `for f in .github/prompts/*.prompt.md; do test -e "$f" && echo "OK: $f" || echo "BROKEN: $f"; done`
