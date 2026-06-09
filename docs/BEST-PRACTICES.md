# Best Practices

## Workflow scripts

- Keep `actions/github-script` blocks short.
- Extract anything non-trivial into `bin/workflow-scripts/` or `bin/sync-state/`.
- Prefer shared helpers for repeated YAML parsing, repo resolution, and audit hooks.

## Repository registry

- Treat `config/repos.yaml` as template data.
- Use placeholders in the boilerplate repo; keep concrete service names in downstream installs.

## Runtime artifacts

- Do not commit generated audit logs or local runtime files.
- Keep `.sdd-audit/*.jsonl` ignored and leave only `.gitkeep` in the directory.

## Readability

- Favor small, single-purpose files over long inline workflow scripts.
- Keep commit messages and PR bodies aligned with the actual repo state.
