---
# ─────────────────────────────────────────────────────────────────────────────
# Epic Metadata (machine-parseable)
# ─────────────────────────────────────────────────────────────────────────────
id: null              # Sequential number (e.g., 1, 2, 3)
title: ""
status: pending       # pending | active | paused | ready-for-deployment | deployed | done | abandoned
complexity: null      # Fibonacci: 1 | 2 | 3 | 5 | 8 | 13 — overall epic sizing
created: null         # YYYY-MM-DD
last_updated: null    # YYYY-MM-DD
owner: ""             # Human responsible (Product Owner / Tech Lead)

# Jira integration
jira_epic: null       # e.g., PROJ-54112 (created after epic is confirmed)

# Multi-repo scope
scope:
  repos: []           # All repos this epic touches (must match repos.yaml keys)
  primary_repo: null  # Where most changes happen (optional, for context)

# Approval tracking (replaces folder-based approval)
approval:
  approved_by: null
  approved_at: null   # YYYY-MM-DD
  # If status changes to 'renegotiating', previous approval is void until re-approved

# References (agents MUST read linked docs during epic conversation and task planning)
references:
  confluence: []      # Confluence page URLs (PRDs, specs, research)
  figma: []           # Figma design URLs
  contracts: []       # Relevant interface contracts from hub's contracts/
  architectural_schemas: []  # Relevant topology docs from architectural-schemas/
  other: []           # Any other relevant links (Jira, Notion, Loom, Slack threads)
---

# Epic: <EPIC_NAME>

## Problem Statement

_Why does this work need to exist? What user or business problem are we solving? Why now?_

## Product Vision

_What does the world look like when this is done? Describe the end-state from the user's perspective._

## Requirements

_Numbered product requirements. These are outcomes, not implementation details._

- **R1.** ...
- **R2.** ...
- **R3.** ...

## Success Criteria

<!-- Notation: use EARS patterns for system/API-level criteria (e.g., "WHEN a vendor..., the system SHALL...") -->
<!-- and Given/When/Then for behavioral/UI criteria. See common-specs/writing-specs.md for the full reference. -->

_How do we know this is done and working? Measurable where possible._

- [ ] ...
- [ ] ...

## Scope Boundaries

### In Scope

- ...

### Out of Scope

- ...

## Repos Involved

_Which repositories are affected by this epic and why. This section connects to `scope.repos` in the frontmatter._

| Repo | Role in this epic | Type of changes |
|------|-------------------|-----------------|
| `repo-name` | _e.g., "New API endpoint"_ | _e.g., "Backend logic + DB migration"_ |

## Technical Constraints

_Anything the breakdown/implementation must respect — existing patterns, data requirements, migration concerns, performance budgets, cross-repo interface contracts, etc._

- ...

## Cross-Repo Dependencies

_How do changes in one repo affect or depend on changes in another? Document interface contracts, deployment ordering requirements, and integration points._

- ...

## Experiment Design (if applicable)

_Remove this section entirely if no experiment is involved._

| Variant | Description | Allocation |
|---|---|---|
| Control | ... | ...% |
| Variant B | ... | ...% |

**Hypothesis:** ...
**Primary metric:** ...
**Duration:** ...
**Cleanup plan:** ...

## Decisions Made During Discovery

_Key decisions from the interactive discovery session (Prompt 5). These provide context for why certain approaches were chosen._

| # | Question | Decision | Rationale |
|---|---|---|---|
| 1 | ... | ... | ... |

## Definition of Done

_Established during epic creation (Prompt 5). Defines what "done" means for the entire epic — beyond individual task completion._

- [ ] **Deployment:** [Feature flags removed / staged rollout complete / fully launched]
- [ ] **Monitoring:** [Alerts configured / dashboards created / error rate baseline confirmed]
- [ ] **Sign-offs:** [QA regression pass / PM acceptance / stakeholder demo]
- [ ] **Documentation:** [User docs updated / training materials delivered / runbook created]
- [ ] **Success metrics:** [Metric X meets threshold Y within Z time period]
- [ ] **Manual steps:** All `delivery.yaml → manual_steps` entries have `completed_at` set (if any). Epics without manual steps can skip this criterion.

_Adjust or remove criteria that don't apply. Add project-specific criteria as needed._

## References

- _Links to designs, PRDs, Slack threads, related epics, etc._
