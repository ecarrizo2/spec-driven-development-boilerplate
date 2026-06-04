# Per-Repo Documentation

This directory contains architecture documentation for repos managed by this hub.

## When to Use This

Documentation here serves as a **fallback** for repos that don't have their own architecture docs. The resolution order is:

1. **Check the repo itself:** `repos/<name>/architecture-documentation/` or `repos/<name>/sdd/agent-specs/`
2. **Fall back here:** `documentation/<name>/`

## Structure

Each repo gets its own subdirectory:

```
documentation/
├── repo-name-1/
│   ├── overview.md        ← What the service does, domain concepts, key workflows
│   └── architecture.md   ← How it's built: folder structure, patterns, DB schema
├── repo-name-2/
│   └── overview.md
└── ...
```

## Content Guide

### `overview.md`
- What the service/app does
- Who uses it (users, other services)
- Key workflows and domain concepts
- External dependencies (APIs it calls, queues it consumes)

### `architecture.md`
- Directory/folder structure
- Design patterns in use
- Database schema overview
- Key modules and their responsibilities
- Deployment topology
