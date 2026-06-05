---
id: 1
title: "Test Automation Epic"
status: active
complexity: 3
created: 2026-06-04
last_updated: 2026-06-04
repos: [example-api]
---

# Test Automation Epic

## Problem Statement
Verify that all SDD automation workflows trigger correctly on GitHub.

## Requirements
- Guardrails must fire on SDD branches and skip on non-SDD branches
- Preflight must validate config and secrets
- Validate must check YAML and frontmatter
- AI verification must handle verify-pr events

## Definition of Done
- All guardrail check runs appear on SDD PRs
- No guardrail noise on non-SDD PRs
- Sync-state CLI commands work
