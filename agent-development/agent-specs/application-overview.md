# Application Overview — Hub Level

> **This file describes the hub itself, NOT any specific managed repo.**
> For repo-specific context, see `fallback-sdd/<repo>/agent-specs/` or `repos/<repo>/sdd/agent-specs/`.

## What This Hub Does

This is a multirepo coordination hub for **[DOMAIN NAME]**. It manages cross-repo epics, task graphs, and delivery manifests for a microservices architecture.

## Managed Repositories

See `config/repos.yaml` for the full registry. Key services:

| Repo | Role |
|------|------|
| _example-api_ | _Backend API_ |
| _example-frontend_ | _User-facing frontend_ |

## System Topology

See `architectural-schemas/system-overview.md` for the full service diagram.

## Key Workflows

1. **Epic Planning** — Define cross-repo features, break into task graphs
2. **Task Dispatch** — Send refined requests to target repos for execution
3. **Execution Tracking** — Monitor task/PR status across all repos via delivery manifests
4. **Coordination** — Manage dependencies, merge ordering, and deployment sequencing
