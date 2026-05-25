# Agent Instructions — Hub Level

> **These instructions apply when working at the HUB level (coordination mode).**
> When executing a task INSIDE a specific repo, read that repo's own agent-instructions instead.

## Hub-Level Work

When operating at the hub level, you are doing **coordination work**:
- Planning epics
- Breaking down task graphs
- Dispatching tasks
- Updating delivery manifests
- Reviewing cross-repo status

## Rules for Hub Operations

1. **Use `bin/dev` commands** — Never run raw git submodule commands
2. **Don't modify repo code from hub context** — Switch to execution mode (inside the repo) for code changes
3. **Keep YAML valid** — All frontmatter and config files must parse cleanly
4. **Cross-reference consistency** — Task IDs in task-graph must match request files; repo names must match repos.yaml keys
5. **Source code > specs** — If code contradicts a spec, code wins

## Rules for Repo-Level Execution

When switched to execution mode (working inside `repos/<name>/`):

1. **Read the spec cascade** — Task plan → repo specs → hub docs → common specs
2. **Respect blast radius** — Only touch files declared in the plan
3. **Follow the Sync Rule** — Update both local AND hub state when done
4. **Use the repo's own bin/dev** for build/test/lint commands
5. **Coding standards are per-repo** — Read the repo's `agent-instructions.md`, not this file

## YAML Conventions

- Use `null` for empty/unset values (not empty string or omitting the field)
- Dates: `YYYY-MM-DD` format
- Status enums: use exact values from STATUS-REFERENCE.md
- Repo names: must exactly match keys in `config/repos.yaml`
