# Jira Ticket Templates for SDD Tasks

> **Location:** `config/jira-ticket-templates.md` (hub root — canonical)
> **Used by:** Prompt 7 (Refine Request), Prompt 5/6 (Epic Creation), Prompt 9 (Amend Epic)
> **Purpose:** Defines the minimum content standard for Jira tickets created from SDD tasks and epics.
> Jira tickets look the same regardless of target repo — this is the single hub-level template with no repo-level overrides.

---

## When to Use Which Template

| Moment | Template | Trigger |
|--------|----------|---------|
| After task refinement (Prompt 7) | **Standard Task Ticket** | Task status moves to `refined` |
| After plan approval | **Enriched Ticket** (optional) | Plan status moves to `approved` |
| Experiment-related task | **Experiment Task Ticket** | Task involves A/B test infrastructure |
| After epic is confirmed and Jira epic needed | **Epic Ticket Template** | End of Prompt 5 / Prompt 6 |

---

## Standard Task Ticket

Use this template when creating Jira tickets after a task has been refined (Prompt 7). This is the **minimum content bar** — every ticket must have at least this level of detail.

### Title

```
[Verb] [Object] — [Context]
```

Examples:
- "Create vendorAwardsAtom data layer"
- "Migrate BestOfWeddingsExpandedBadge to atom pattern"
- "Register awards enhancement experiment in Flipper"

### Description

```markdown
## Context

- **Epic:** [PROJ-XXX] <Epic Title>
- **Task:** N of M in epic task graph
- **Target repo:** <repo-name> (from config/repos.yaml)
- **Depends on:** [PROJ-YYY], [PROJ-ZZZ] (or "None — independent")
- **Blocks:** [PROJ-AAA] (or "None")
- **Cross-repo deps:** [Describe any cross-repo dependency, e.g., "Requires PROJ-YYY in awards-api to merge first"]

<!-- 2-3 sentences on the current state and what changes -->

## Product Brief

- [Link to PRD/Confluence page]

## Design

- **Figma:** [URL]
- **Notes:** [Any design-specific notes]

## Goal

<!-- What does "done" look like for this task? 1-2 sentences. -->

## Requirements

- **R1.** [First concrete requirement]
- **R2.** [Second concrete requirement]
- **R3.** [Third concrete requirement]

## Acceptance Criteria

<!-- Use EARS notation for system/API-level criteria (preferred):         -->
<!--   WHEN <trigger>, the system SHALL <response>                        -->
<!--   IF <unwanted condition>, the system SHALL <response>               -->
<!-- Use Given/When/Then for UI/behavioral flow criteria.                 -->
<!-- See common-specs/writing-specs.md for the full EARS pattern reference. -->
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Dev Notes

- **Target repo:** <repo-name>
- **New component?** Yes / No
- **Modifies existing component?** Yes / No — [which one]
- **Key files:** [paths to primary files affected]
- **Pattern to follow:** [reference to existing pattern in codebase]

## Cross-Team Information

- **Impacted teams:** [Team names and contacts, or "None"]
- **API endpoints:** [Endpoints affected, or "N/A"]
- **External repos:** [Other repos involved, or "N/A"]
- **Contracts:** [Reference to contracts/ file if applicable]

## Resources

- [Link to SDD request file in hub repo]
- [Link to epic.md]
- [Any other relevant links]
```

---

## Experiment Task Ticket

Use this **in addition to** the Standard template when the task involves A/B test experiment infrastructure.

### Additional Sections (append after Dev Notes)

```markdown
## A/B Test Experiment

**Experiment Name:** [Name as registered in experimentation platform]

### Variants and Allocations

| Variant | Description | Allocation |
|---------|-------------|------------|
| Control | [Description] | XX% |
| Variant 1 | [Description] | XX% |
| Variant 2 | [Description] | XX% |

### Experiment URLs

**QA:**
- Flipper URL: [URL]
- Flipper ID: [ID]
- Control: `https://qa-beta.theknot.com?vers=0`
- Variant 1: `https://qa-beta.theknot.com?vers=1`
- Variant 2: `https://qa-beta.theknot.com?vers=2`

**PROD:**
- Flipper URL: [URL]
- Flipper ID: [ID]
- Control: `www.theknot.com?vers=0`
- Variant 1: `www.theknot.com?vers=1`
- Variant 2: `www.theknot.com?vers=2`

### Important Experiment Notes

- [Any critical notes about experiment setup, duration, metrics]
```

---

## Enriched Ticket (Optional)

After a plan is approved, optionally update the ticket with implementation-level detail.

### Additional Sections (append to existing ticket)

```markdown
## Implementation Plan Summary

- **Total stages:** N
- **Estimated LOC:** ~XXX
- **Key decisions:**
  - [Decision 1 and rationale]
  - [Decision 2 and rationale]

## QA Testing Notes

- [How to verify this task works correctly]
- [Specific test scenarios to run]
- [Environment setup needed]

## Edge Cases Handled

- [Edge case 1 and how it's handled]
- [Edge case 2 and how it's handled]
```

---

## Guidelines

1. **Acceptance Criteria are mandatory** — Every ticket must have at least 3 concrete, verifiable acceptance criteria.
2. **Link dependencies as Jira issue links** — Use "Blocks" / "Is Blocked By" relationships.
3. **Keep the Description self-contained** — A developer should understand the task without opening the hub repo.
4. **Use consistent verb prefixes** in titles: Create, Migrate, Register, Add, Remove, Refactor, Fix, Update.
5. **Tag with epic** — Always set the Epic Link field in Jira to the parent epic ticket.
6. **Include target repo** — Always specify which repo the task executes in.

---

## Epic Ticket Template

Use this template when creating the Jira epic ticket at the end of Prompt 5 (epic discovery) or Prompt 6 (task graph breakdown). Template sections map 1:1 to fields in `epics/_templates/epic.md` for agent auto-population.

### Title Format

```
[Initiative]: [Outcome]
```

Examples:
- "Feature Area: surface key capability on primary page"
- "Data Layer: unified atom with experiment infrastructure"

### Description

```markdown
## Problem Statement

<!-- Maps to: epic.md → Problem Statement -->
<!-- Why does this work need to exist? What user or business problem are we solving? Why now? -->

## Product Vision

<!-- Maps to: epic.md → Product Vision -->
<!-- What does the world look like when this is done? Describe the end-state from the user's perspective. -->

## Success Metrics

<!-- Maps to: epic.md → Success Criteria -->
<!-- Measurable criteria that define success for the epic. Use EARS notation for system-level metrics. -->
- [ ] [Metric 1 — measurable, with target value if known]
- [ ] [Metric 2]

## Scope: In

<!-- Maps to: epic.md → Scope Boundaries → In Scope -->
- [What the epic will deliver]

## Scope: Out

<!-- Maps to: epic.md → Scope Boundaries → Out of Scope -->
<!-- Explicit exclusions prevent scope creep in Jira conversations. -->
- [What the epic will NOT deliver]

## Repos Involved

<!-- Maps to: epic.md → Repos Involved + scope.repos frontmatter -->

| Repo | Role in this epic | Type of changes |
|------|-------------------|------------------|
| `repo-name` | [e.g., "New API endpoint"] | [e.g., "Backend logic + DB migration"] |

## Links

<!-- Maps to: epic.md → references frontmatter -->
- **Confluence PRD:** [URL]
- **Figma designs:** [URL]
- **Hub epic.md:** [path in this repo, e.g., epics/1-epic-name/epic.md]

## Task Summary

<!-- Populated after Prompt 6 completes the task graph. -->
<!-- Update status column as tasks are completed. -->

| Task | Title | Repo | Depends on | Status |
|------|-------|------|------------|--------|
| 1 | [Title] | [repo] | None | planned |
| 2 | [Title] | [repo] | Task 1 | draft |

## Definition of Done

<!-- Maps to: epic.md → Definition of Done -->
<!-- This epic ticket is not "Done" in Jira until ALL items below are checked. -->
- [ ] **Deployment:** [Feature flags removed / staged rollout complete / fully launched]
- [ ] **Monitoring:** [Alerts configured / dashboards created / error rate baseline confirmed]
- [ ] **Sign-offs:** [QA regression pass / PM acceptance / stakeholder demo]
- [ ] **Documentation:** [User docs updated / training materials delivered / runbook created]
- [ ] **Success metrics:** [Metric X meets threshold Y within Z time period]
- [ ] **Manual steps:** All `delivery.yaml → manual_steps` entries completed (if any)
```

### When to Update the Epic Ticket

| Moment | What to update |
|--------|---------------|
| After Prompt 6 (task graph finalized) | Add child ticket links to Task Summary table; link child tickets to epic in Jira |
| After each task is completed | Update Task Summary table status for that task |
| After epic amendments (Prompt 9 / sdd-amend-epic) | Update Scope In/Out, Repos Involved, Task Summary as needed |
